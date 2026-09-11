package com.huaweidigi.app2;

import android.app.PendingIntent;
import android.app.Service;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.SQLException;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.PowerManager;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class TTSForegroundService extends Service {

    private SoundPool soundPool;
    private int dingId;
    //private boolean isSoundPoolLoaded = false;

    private TextToSpeech tts;
    private ScheduledExecutorService scheduler;
    private ScheduledExecutorService timeUpdater;

    private ExecutorService taskQueue;

    private final BlockingQueue<SpeechTask> speechQueue = new LinkedBlockingQueue<>();
    private boolean isProcessingQueue = false;

    private boolean isTtsInitialized = false;

    public class SpeechTask {
        public final String no;
        public final String message;

        public SpeechTask(String no, String message) {
            this.no = no;
            this.message = message;
        }
    }

    private PowerManager.WakeLock wakeLock;

    @Override
    public void onCreate() {
        super.onCreate();

        // 初始化 SoundPool
        soundPool = new SoundPool.Builder().setMaxStreams(1).build();
        dingId = soundPool.load(this, R.raw.ding, 1);

        // 監聽是否載入完成
        /*
        soundPool.setOnLoadCompleteListener((pool, sampleId, status) -> {
            if (status == 0) {
                isSoundPoolLoaded = true;
                Log.d("TTS", "SoundPool 載入完成");
            }
        });

         */

        // 🔋 保持 CPU 醒著
        PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
        wakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "TTSForegroundService::WakeLock"
        );
        wakeLock.acquire();

        taskQueue = Executors.newSingleThreadExecutor();

        // 初始化 TTS（使用台灣中文語音）
        Log.e("TTS", "初始化 TTS（使用台灣中文語音）");
        tts = new TextToSpeech(getApplicationContext(), status -> {
            if (status != TextToSpeech.ERROR) {
                String engine = tts.getDefaultEngine();
                Log.i("TTS", "目前 TTS 引擎：" + engine);
                int availability = tts.isLanguageAvailable(Locale.TAIWAN);
                Log.d("TTS", "語言可用性代碼：" + availability);

                if (availability >= TextToSpeech.LANG_AVAILABLE) {
                    tts.setLanguage(Locale.TAIWAN);
                    isTtsInitialized = true;
                    Log.i("TTS", "TTS 初始化成功");
                } else if (availability == TextToSpeech.LANG_MISSING_DATA) {
                    Log.w("TTS", "缺少語音資料，嘗試引導安裝");
                    Intent installIntent = new Intent();
                    installIntent.setAction(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA);
                    installIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(installIntent);
                } else {
                    Log.e("TTS", "TTS 不支援 Locale.TAIWAN");
                }


                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1) {
                    tts.setOnUtteranceProgressListener(new UtteranceProgressListener() {
                        @Override
                        public void onStart(String utteranceId) {
                            Log.d("TTS", "開始播報: " + utteranceId);
                        }

                        @Override
                        public void onDone(String utteranceId) {
                            Log.d("TTS", "播報完成: " + utteranceId);
                            MainActivity.notifyFlutterComplete("");
                            updateCompleteStatus(utteranceId); // ✅ 播報完成後更新狀態
                            //isProcessingQueue = false;
                            if (speechQueue.isEmpty()) {
                                // 佇列已經沒有任務了
                                isProcessingQueue = false;
                            }
                            else{
                                processSpeechQueue(); // 播下一筆
                            }

                        }

                        @Override
                        public void onError(String utteranceId) {
                            Log.e("TTS", "播報錯誤: " + utteranceId);
                            //isProcessingQueue = false;
                            //processSpeechQueue(); // 錯誤也繼續下一筆
                        }
                    });
                }

            }
            else{
                Log.e("TTS", "TTS 初始化失敗");
            }
        },"com.google.android.tts");


        // 每 5 秒呼叫 API 檢查是否要播報語音
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(this::callApiAndSpeak, 0, 6, TimeUnit.SECONDS);

        // 每 1 秒更新通知時間
        timeUpdater = Executors.newSingleThreadScheduledExecutor();
        timeUpdater.scheduleAtFixedRate(this::updateNotificationTime, 0, 1, TimeUnit.SECONDS);
    }

    private String findClassName(JSONArray classArray, String classNo) throws JSONException {
        for (int i = 0; i < classArray.length(); i++) {
            JSONObject cls = classArray.getJSONObject(i);
            if (classNo.equals(cls.optString("CLASS_NO"))) {
                return cls.optString("CLASS_NM");
            }
        }
        return null;
    }

    private String findCustomerName(JSONArray customerArray, String csNo) throws JSONException {
        for (int i = 0; i < customerArray.length(); i++) {
            JSONObject cs = customerArray.getJSONObject(i);
            if (csNo.equals(cs.optString("CS_NO"))) {
                return cs.optString("CS_NM");
            }
        }
        return null;
    }

    private void callApiAndSpeak() {

        Log.e("TTS", "isTtsInitialized:"+isTtsInitialized);

        if(isTtsInitialized==false) return;

        if (isProcessingQueue) return; // 正在播報中就跳過

        Log.d("TTS", "重新撈取要播報的資料: ");

        /*
        PreparedStatement cs=null;
        String ConnURL;
        ResultSet rs = null;
        String _sql_respround="";
        Connection conn = null;
        String SQL_IP = "www.tw-wilson.com:1433";//"123.252.108.29";
        String SQL_NAME = "APP";
        String SQL_LOGIN_ACCOUNT = "sa";
        String SQL_LOGIN_PASSWORD = "Ws53826282";


        try {

            try {
                // 如果連接不存在或已關閉，重新建立連接
                if (conn == null || conn.isClosed()) {
                    System.out.println("重新建立連接");
                    Class.forName("net.sourceforge.jtds.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:jtds:sqlserver://"+SQL_IP+"/"+SQL_NAME+";user=" + SQL_LOGIN_ACCOUNT + ";password=" + SQL_LOGIN_PASSWORD+";useLOBs=false;ssl=require");
                    System.out.println("Connection established successfully!");
                } else {
                    // 可選：執行簡單查詢檢查連接是否有效

                    try (Statement stmt = conn.createStatement()) {
                        stmt.executeQuery("SELECT 1 FROM DAILY_MT_TYPE_ITEM");
                        System.out.println("Connection is 有效");
                    } catch (SQLException ex) {
                        System.out.println("重新建立連接");
                        System.out.println("Connection lost. Reconnecting...");
                        conn = DriverManager.getConnection("jdbc:jtds:sqlserver://"+SQL_IP+"/"+SQL_NAME+";user=" + SQL_LOGIN_ACCOUNT + ";password=" + SQL_LOGIN_PASSWORD+";useLOBs=false;ssl=require");

                    }

                }
            } catch (ClassNotFoundException | SQLException e) {
                e.printStackTrace();
            }


            cs=conn.prepareStatement("SELECT * FROM View_LOGIN");
            cs.setEscapeProcessing(true);
            cs.setQueryTimeout(20);



            JSONArray jsonArray = new JSONArray();
            rs = cs.executeQuery();
            ResultSetMetaData metaData = rs.getMetaData();
            int count = metaData.getColumnCount();
            String[] columnName = new String[count];
            while(rs.next()) {
                JSONObject jsonObject = new JSONObject();
                for (int i = 1; i <= count; i++){
                    columnName[i-1] = metaData.getColumnLabel(i);
                    jsonObject.put(columnName[i-1], rs.getObject(i));
                }
                jsonArray.put(jsonObject);
            }
            Log.d("回應3", ""+jsonArray);
            speak("家長要來接小孩");

        }
        catch (SQLException se) {
            Log.e("ERROR-1", se.getMessage());

        }
        catch (Exception e) {
            Log.e("ERROR-3", e.getMessage());
            Log.e("ERROR-3", e.getLocalizedMessage());
        }
        */



        try {

            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
            Boolean is_debug = prefs.getBoolean("is_debug",false);
            Log.d("is_debug", ""+is_debug); // ✅ 印出整個回傳內容
            if(is_debug) return; // 如為debug就不執行更新


            String account = prefs.getString("ACCOUNT", null);
            String DEPM_NO = prefs.getString("DEPM_NO", null);
            URL url = new URL("https://tw-wilson.com/api/v2/data");
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();

            // 設定為 POST
            connection.setRequestMethod("POST");
            connection.setConnectTimeout(4000);
            connection.setReadTimeout(4000);
            connection.setDoOutput(true); // 允許寫入輸出
            connection.setDoInput(true);

            // 設定 headers
            connection.setRequestProperty("Content-Type", "application/json");
            if (account != null) {
                //connection.setRequestProperty("Authorization", "Bearer " + account);
                connection.setRequestProperty("Authorization", "WILSONq7tXJpA4Mvksf2y1bZ9hQnE6R3oFLUu8mCgxYr0VdzKNTijw5aOBGPHclSDe");
            }

            // 建立要傳送的 JSON body
            JSONObject body = new JSONObject();
            body.put("sql_command", "SELECT * FROM View_CALL WHERE COMPLETE='false' AND PLAY = 'true' AND CONVERT(DATE, ARRIVAL_TIME) = CONVERT(DATE, GETDATE()) "+" AND DEPM_NO='"+DEPM_NO+"'"+" ORDER BY ARRIVAL_TIME ASC" );

            // 寫入 body 資料
            try (OutputStream os = connection.getOutputStream()) {
                byte[] input = body.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            // 取得回應
            int responseCode = connection.getResponseCode();
            //Log.e("responseCode", ""+responseCode);

            if (responseCode == 200) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                StringBuilder responseBuilder = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    responseBuilder.append(line);
                }
                reader.close();

                String responseString = responseBuilder.toString();

                Log.d("respround", responseString); // ✅ 印出整個回傳內容

                try {

                    String classJsonStr = prefs.getString("CLASS", "[]");
                    String customerJsonStr = prefs.getString("CUSTOMER", "[]");
                    JSONArray classArray = new JSONArray(classJsonStr);
                    JSONArray customerArray = new JSONArray(customerJsonStr);

                    JSONArray jsonArray = new JSONArray(responseString);
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject item = jsonArray.getJSONObject(i);
                        boolean complete = item.optBoolean("COMPLETE", true);
                        String no = item.optString("NO");
                        String MINUTE = item.optString("MINUTE");
                        String classNo = item.optString("CLASS_NO");
                        String csNo = item.optString("CS_NO");
                        String note = item.optString("NOTE");

                        if (!complete) {
                            String className = findClassName(classArray, classNo);
                            String customerName = findCustomerName(customerArray, csNo);
                            // 過濾數字開頭的格式
                            customerName = customerName.trim().replaceFirst("^\\d+", "").replace("-", "");
                            speechQueue.offer(new SpeechTask(no, ""+className+","+customerName+","+customerName+",家長"+note)); // 加入佇列
                        }
                    }

                    Log.d("TTS", "處理佇列-start");
                    processSpeechQueue(); // 處理佇列

                } catch (JSONException e) {
                    e.printStackTrace();
                    Log.e("JSON_ERROR", "無法解析回傳 JSON");
                }
            }

            connection.disconnect();

            // 更新通知時間
            NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
            Notification notification = createNotification(); // 會包含最新時間
            if (manager != null) {
                manager.notify(1, notification); // ID 必須和 startForeground 的相同
            }

        } catch (Exception e) {
            e.printStackTrace();
            isProcessingQueue = false; // 發生網路錯誤時，允許下一次排程重新啟動
        }



    }



    /*
    private void processSpeechQueue() {
        if (isProcessingQueue) return;

        isProcessingQueue = true;

        taskQueue.submit(() -> {
            try {
                while (!speechQueue.isEmpty()) {

                    SpeechTask task = speechQueue.poll();
                    if (task != null) {

                        // 更新完 Server 後，通知 Flutter
                        MainActivity.notifyFlutterComplete(task.no);
                        speak(task.message);

                        // 等待 tts 開始 speaking
                        while (!tts.isSpeaking()) {
                            try {
                                Thread.sleep(100);
                            } catch (InterruptedException e) {
                                return;
                            }
                        }

                        // 等待 speaking 結束
                        while (tts.isSpeaking()) {
                            try {
                                Thread.sleep(100);
                            } catch (InterruptedException e) {
                                break;
                            }
                        }
                        MainActivity.notifyFlutterComplete("");
                        updateCompleteStatus(task.no); // ✅ 播報完成後更新狀態
                    }
                }
            } finally {
                isProcessingQueue = false;
            }
        });
    }

     */




    private void processSpeechQueue() {
        //if (isProcessingQueue) return;

        SpeechTask task = speechQueue.poll();//取出一筆
        if (task != null) {
            isProcessingQueue = true;
            MainActivity.notifyFlutterComplete(task.no);
            speak(task.message,task.no);

        } else {
            isProcessingQueue = false;
        }
    }


    private void updateCompleteStatus(String no) {
        try {

            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
            String account = prefs.getString("ACCOUNT", null);

            URL url = new URL("https://tw-wilson.com/api/v2/data");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(10000);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            // 設定 headers
            conn.setRequestProperty("Content-Type", "application/json");
            if (account != null) {
                //conn.setRequestProperty("Authorization", "Bearer " + account);
                conn.setRequestProperty("Authorization", "WILSONq7tXJpA4Mvksf2y1bZ9hQnE6R3oFLUu8mCgxYr0VdzKNTijw5aOBGPHclSDe");
            }

            // 建立要傳送的 JSON body
            JSONObject body = new JSONObject();
            body.put("sql_command", "UPDATE CALL SET COMPLETE = 'true' WHERE NO = '" + no + "'");
            Log.d("UPDATE_BODY", body.toString());

            OutputStream os = conn.getOutputStream();
            os.write(body.toString().getBytes("UTF-8"));
            os.close();

            int responseCode = conn.getResponseCode();
            Log.d("UPDATE", "Response code = " + responseCode);
            conn.disconnect();


        } catch (Exception e) {
            e.printStackTrace();
            Log.e("UPDATE_ERROR", e.getMessage());
        }
    }

    private void updateNotificationTime() {
        NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        Notification notification = createNotification(); // 每次都會顯示最新時間
        if (manager != null) {
            manager.notify(1, notification);
        }
    }

    private void speak(String message,String utteranceId) {
        if (tts != null) {

            // 設置為中文（繁體）
            tts.setLanguage(Locale.TAIWAN); // 或者 Locale.CHINESE

            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
            float speechRate = prefs.getFloat("speechRate", 1.0f);  // 這樣你就取得最新的了
            tts.setSpeechRate(speechRate);

            //tts.speak(message, TextToSpeech.QUEUE_FLUSH, null, "tts1");


            // 播放提示音後再播報語音
            /*
            MediaPlayer mediaPlayer = MediaPlayer.create(getApplicationContext(), R.raw.ding);
            if (mediaPlayer != null) {
                mediaPlayer.setOnCompletionListener(mp -> {
                    mp.release(); // 釋放資源
                    Log.d("TTS", "提示音播放完畢，開始播報 TTS");
                    tts.speak(message.replaceAll("頡", "傑").replaceAll("子", "紫").replaceAll("纕", "香").replaceAll("酪", "落").replaceAll("周", "舟").replaceAll("汩", "遇").replaceAll("德", "鍀").replaceAll("筠", "芸").replaceAll("靚", "靜").replaceAll("亘", "軒").replaceAll("少", "邵").replaceAll("曾", "增").replaceAll("晟", "成").replaceAll("鎬", "浩").replaceAll("婕", "節").replaceAll("偲", "思"), TextToSpeech.QUEUE_FLUSH, null, ""+utteranceId);
                });
                mediaPlayer.start(); // 播放提示音
            } else {
                Log.e("TTS", "MediaPlayer 無法建立，直接播報 TTS");
                speak(message,utteranceId);
                //tts.speak(message.replaceAll("曾", "增").replaceAll("晟", "成").replaceAll("鎬", "浩").replaceAll("婕", "節"), TextToSpeech.QUEUE_FLUSH, null, "tts1");
            }

             */

            // 參數說明：音效ID, 左音量, 右音量, 優先級, 循環次數(0不循環), 速率(1.0正常)
            soundPool.play(dingId, 1.0f, 1.0f, 1, 0, 1.0f);

            // SoundPool 是非同步播放，通常叮聲很短（約 1 秒）
            // 為了確保聽起來自然，可以直接使用 QUEUE_FLUSH 播報 TTS
            // 或者稍微延遲 500ms 呼叫 TTS
            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                executeTts(message, utteranceId);
            }, 2500);

        }
    }

    private void executeTts(String text, String utteranceId) {
        // 1. 執行真正的語音播報指令
        // QUEUE_FLUSH 代表中斷目前的播報，立刻改播這則最新的（適合叫號系統）
        //int result = tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, utteranceId);
        int result = tts.speak(text.replaceAll("璿", "旋").replaceAll("頡", "傑").replaceAll("子", "紫").replaceAll("纕", "香").replaceAll("酪", "落").replaceAll("周", "舟").replaceAll("汩", "遇").replaceAll("德", "鍀").replaceAll("筠", "芸").replaceAll("靚", "靜").replaceAll("亘", "軒").replaceAll("少", "邵").replaceAll("曾", "增").replaceAll("晟", "成").replaceAll("鎬", "浩").replaceAll("婕", "節").replaceAll("偲", "思"), TextToSpeech.QUEUE_FLUSH, null, ""+utteranceId);

        // 2. 檢查 API 是否成功執行
        if (result == TextToSpeech.ERROR) {
            Log.e("TTS", "tts.speak 指令執行失敗");
            // 防呆關鍵：如果指令根本發不出去，必須立刻釋放鎖定
            // 否則 isProcessingQueue 會一直鎖在 true，導致後面所有的叫號都進不來
            //isProcessingQueue = false;
            Toast.makeText(getApplicationContext(), "tts.speak 指令執行失敗", Toast.LENGTH_SHORT).show();
            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                executeTts(text, utteranceId);
            }, 2500);

        } else {
            Log.d("TTS", "指令已成功發送至引擎，等待 onDone 回傳...");
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        String msg = intent.getStringExtra("speak_message");
        if (msg != null && !msg.isEmpty()) {
            //speak(msg); // 調用你的播報方法
        }

        startForeground(1, createNotification());
        return START_STICKY;
    }

    private Notification createNotification() {
        String channelId = "tts_channel";
        String channelName = "TTS Service";

        NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        // 當下時間格式
        String currentTime = new SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(new Date());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel chan = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW);
            if (manager != null) {
                manager.createNotificationChannel(chan);
            }


            // 加入 PendingIntent（點通知打開 MainActivity）
            Intent notificationIntent = new Intent(this, MainActivity.class);
            notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            PendingIntent pendingIntent = PendingIntent.getActivity(
                    this,
                    0,
                    notificationIntent,
                    PendingIntent.FLAG_IMMUTABLE // << 這是關鍵！
            );

            return new Notification.Builder(this, channelId)
                    .setContentIntent(pendingIntent)
                    .setContentTitle("接寶Phone監聽中")
                    .setContentText("Time: " + currentTime)
                    .setSmallIcon(R.drawable.notification_icon)
                    .build();
        } else {

            // 加入 PendingIntent（點通知打開 MainActivity）
            Intent notificationIntent = new Intent(this, MainActivity.class);
            notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            PendingIntent pendingIntent = PendingIntent.getActivity(
                    this,
                    0,
                    notificationIntent,
                    PendingIntent.FLAG_IMMUTABLE // << 這是關鍵！
            );

            return new Notification.Builder(this)
                    .setContentIntent(pendingIntent)
                    .setContentTitle("TTS Service Running")
                    .setContentText("Time: " + currentTime)
                    .setSmallIcon(R.drawable.notification_icon)
                    .setPriority(Notification.PRIORITY_LOW)
                    .build();
        }
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
        if (tts != null) {
            tts.stop();
            tts.shutdown();
        }
        if (timeUpdater != null) {
            timeUpdater.shutdownNow();
        }
        if (taskQueue != null) {
            taskQueue.shutdownNow();
        }
        speechQueue.clear();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}