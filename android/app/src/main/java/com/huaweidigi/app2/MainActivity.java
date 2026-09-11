package com.huaweidigi.app2;

import static android.content.Context.MODE_PRIVATE;

import io.flutter.embedding.android.FlutterActivity;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.database.SQLException;
import android.net.Uri;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.os.FileUtils;
import android.os.Looper;
import android.os.PowerManager;
import android.os.StrictMode;
import android.provider.Settings;
import android.util.Log;

import androidx.core.content.ContextCompat;

import org.bouncycastle.util.encoders.Base64;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import androidx.annotation.NonNull;
import jcifs.CIFSContext;
import jcifs.CIFSException;
import jcifs.config.PropertyConfiguration;
import jcifs.context.BaseContext;
import jcifs.smb.NtlmPasswordAuthentication;
import jcifs.smb.NtlmPasswordAuthenticator;
import jcifs.smb.SmbException;
import jcifs.smb.SmbFile;
import jcifs.smb.SmbFileInputStream;
import jcifs.smb.SmbFileOutputStream;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.os.Handler;
import android.media.AudioManager;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    private final Handler handler = new Handler();

    private static final String CHANNEL = "samples.flutter.io/sql";

    private static Connection conn = null;

    private PowerManager.WakeLock wakeLock;

    private static FlutterEngine flutterEngine;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        enableImmersiveMode();

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        // TODO

                        String query="";
                        JSONObject query_obj=null;
                        query = ""+call.method;

                        if (call.method.equals("saveAccount")) {
                            String account = call.argument("account");
                            String DEPM_NO = call.argument("DEPM_NO");

                            // 存入 SharedPreferences
                            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
                            prefs.edit().putString("ACCOUNT", account).apply();
                            prefs.edit().putString("DEPM_NO", DEPM_NO).apply();

                            result.success("saved");
                        }
                        else if (call.method.equals("getSpeechRate")) {
                            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
                            float rate = prefs.getFloat("speechRate", 1.0f);
                            result.success((double) rate);  // 回傳給 Flutter
                        }
                        else if (call.method.equals("setSpeechRate")) {
                            double rate = call.argument("rate");
                            float newRate = (float) rate;

                            // 儲存至 SharedPreferences，TTSForegroundService 會自己讀
                            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
                            prefs.edit().putFloat("speechRate", newRate).apply();

                            result.success("rate set");
                        }
                        else if (call.method.equals("getVolume")) {
                            AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                            int currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
                            int maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);

                            float volume = (float) currentVolume / maxVolume;
                            result.success(volume); // 回傳 0.0 ~ 1.0 之間的音量
                        }
                        else if (call.method.equals("setVolume")) {
                            double volume = call.argument("volume"); // 預期為 0.0 ~ 1.0
                            AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                            int maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
                            int newVolume = (int) (volume * maxVolume);

                            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVolume, AudioManager.FLAG_SHOW_UI);
                            result.success("volume set");
                        }
                        else if (call.method.equals("debug")) {
                            Boolean is_debug = call.argument("is_debug");

                            // 存入 SharedPreferences
                            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
                            prefs.edit().putBoolean("is_debug", is_debug).apply();

                            result.success("saved");
                        }
                        else if (call.method.equals("saveCLASS")) {
                            String CLASS = call.argument("CLASS");

                            // 存入 SharedPreferences
                            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
                            prefs.edit().putString("CLASS", CLASS).apply();

                            result.success("saved");
                        }
                        else if (call.method.equals("saveCUSTOMER")) {
                            String CLASS = call.argument("CUSTOMER");

                            // 存入 SharedPreferences
                            SharedPreferences prefs = getSharedPreferences("AppPrefs", MODE_PRIVATE);
                            prefs.edit().putString("CUSTOMER", CLASS).apply();

                            result.success("saved");
                        }
                        else if (query.equals("speak")) {
                            String message = call.argument("message");

                            // 確保 Service 正在執行
                            Intent intent = new Intent(MainActivity.this, TTSForegroundService.class);
                            intent.putExtra("speak_message", message);
                            ContextCompat.startForegroundService(MainActivity.this, intent);

                            result.success(null);
                        }
                        else if(query.contains("startService")){

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
                                if (!pm.isIgnoringBatteryOptimizations(getPackageName())) {
                                    Intent intent = new Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
                                    intent.setData(Uri.parse("package:" + getPackageName()));
                                    startActivity(intent);
                                }
                            }

                            PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
                            wakeLock = powerManager.newWakeLock(
                                    PowerManager.FULL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP,
                                    "TTSService::WakeLock"
                            );
                            wakeLock.acquire();

                            Intent intent = new Intent(MainActivity.this, TTSForegroundService.class);
                            ContextCompat.startForegroundService(MainActivity.this, intent);
                            result.success("started");
                        }
                        else if(query.contains("stopService")){
                            if (wakeLock != null && wakeLock.isHeld()) {
                                wakeLock.release();
                                Log.d("TTSService", "WakeLock 已釋放");
                            }
                            Intent intent = new Intent(MainActivity.this, TTSForegroundService.class);
                            stopService(intent);
                            result.success("stopped");
                        }
                        else if(query.contains("SMB_SERVER")){

                            try {

                                query_obj = new JSONObject(query);

                                CIFSContext baseCxt = new BaseContext(new PropertyConfiguration(System.getProperties()));
                                NtlmPasswordAuthenticator auth = new NtlmPasswordAuthenticator(query_obj.getString("userName"), query_obj.getString("password"));
                                CIFSContext ct = baseCxt.withCredentials(auth);
                                SmbFile smbFile = new SmbFile(query_obj.getString("remoteURL"), ct);
                                SmbFileOutputStream smbfos = new SmbFileOutputStream(smbFile);

                                byte[] valueDecoded = Base64.decode(query_obj.getString("file"));
                                smbfos.write(valueDecoded);
                                smbfos.flush();
                                smbfos.close();
                                System.out.println("completed ...nice !");
                                result.success("completed ...nice !");


                                /*
                                byte[] BUFFER = new byte[10 * 8024];
                                ByteArrayInputStream inputStream = null;
                                SmbFileOutputStream sfos = null;

                                String user = query_obj.getString("userName") + ":" + query_obj.getString("password");
                                //int lenghtOfFile = (int) localFile.length();
                                byte[] data = FileUtils.readFileToByteArray(localFile);
                                inputStream = new ByteArrayInputStream(data);
                                String path = destinationPath + localFile.getName();
                                NtlmPasswordAuthentication auth = new NtlmPasswordAuthentication(user);
                                remoteFile = new SmbFile(path, auth);
                                sfos = new SmbFileOutputStream(remoteFile);
                                long total = 0;
                                while ((count = inputStream.read(BUFFER)) > 0) {
                                    total += count;
                                    // publishing the progress....
                                    // After this onProgressUpdate will be called
                                    int percentage = (int) ((total / (float) lenghtOfFile) * 100);
                                    //publishProgress(percentage);
                                    //  publishProgress((int) ((total * 100) / lenghtOfFile));
                                    // writing data to file
                                    sfos.write(BUFFER,0,count);

                                }
                                sfos.flush();
                                inputStream.close();
                                sfos.close();

                                 */



                                /*
                                CIFSContext baseCxt = new BaseContext(new PropertyConfiguration(System.getProperties()));
                                NtlmPasswordAuthenticator auth = new NtlmPasswordAuthenticator(query_obj.getString("userName"), query_obj.getString("password"));
                                CIFSContext ct = baseCxt.withCredentials(auth);
                                SmbFile smbFile = new SmbFile(query_obj.getString("remoteURL") + query_obj.getString("remoteFile"), ct);

                                SmbFileInputStream inputSmbFileStream = new SmbFileInputStream(smbFile);
                                File localFile = new File(filePath);
                                FileOutputStream outputFileStream = new FileOutputStream(localFile);

                                byte[] buffer = new byte[4096];
                                int length = 0;
                                while ((length = inputSmbFileStream.read(buffer)) > 0) {
                                    outputFileStream.write(buffer, 0, length);
                                }

                                outputFileStream.close();
                                inputSmbFileStream.close();

                                 */
                            }
                            catch (CIFSException e) {
                                e.printStackTrace();
                                result.success(e.getMessage());
                            } catch (FileNotFoundException e) {
                                e.printStackTrace();
                                result.success(e.getMessage());
                            }  catch (IOException e) {
                                e.printStackTrace();
                                result.success(e.getMessage());
                            } catch (JSONException e) {
                                e.printStackTrace();
                                result.success(e.getMessage());
                            }

                        }
                        else{


                            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder()
                                    .permitAll().build();
                            StrictMode.setThreadPolicy(policy);
                            PreparedStatement cs=null;
                            String ConnURL;
                            ResultSet rs = null;
                            String _sql_respround="";


                            try {

                                query = ""+call.method;
                                query_obj = new JSONObject(query);


                                try {
                                    // 如果連接不存在或已關閉，重新建立連接
                                    if (conn == null || conn.isClosed()) {
                                        System.out.println("重新建立連接");
                                        Class.forName("net.sourceforge.jtds.jdbc.Driver");
                                        conn = DriverManager.getConnection(query_obj.getString("url"));
                                        System.out.println("Connection established successfully!");
                                    } else {
                                        // 可選：執行簡單查詢檢查連接是否有效

                                        try (Statement stmt = conn.createStatement()) {
                                            stmt.executeQuery("SELECT 1 FROM DAILY_MT_TYPE_ITEM");
                                            System.out.println("Connection is 有效");
                                        } catch (SQLException ex) {
                                            System.out.println("重新建立連接");
                                            System.out.println("Connection lost. Reconnecting...");
                                            conn = DriverManager.getConnection(query_obj.getString("url"));
                                        }

                                    }
                                } catch (ClassNotFoundException | SQLException e) {
                                    e.printStackTrace();
                                }

                                /*
                                Log.d("成功1", "this for local ip, use ip or your pc name which has server (mssql 3031) in it");
                                Class.forName("net.sourceforge.jtds.jdbc.Driver").newInstance();
                                DriverManager.setLoginTimeout(5);
                                //conn = DriverManager.getConnection("jdbc:jtds:sqlserver://tjteck.com:5678/iWMS_YC;user=" + "rf" + ";password=" + "rf");
                                conn = DriverManager.getConnection(query_obj.getString("url"));
                                Log.d("成功2", "this for local ip, use ip or your pc name which has server (mssql 3031) in it");

                                 */


                                Log.d("下命令", ""+query);
                                cs=conn.prepareStatement(query_obj.getString("command"));
                                cs.setEscapeProcessing(true);
                                cs.setQueryTimeout(60);




                                JSONArray jsonArray = new JSONArray();
                                if((""+query_obj.getString("command")).contains("INSERT")){
                                    Log.d("回應3", "cs.executeUpdate()");
                                    cs.executeUpdate();
                                }
                                else{
                                    Log.d("回應3", "cs.executeQuery()");
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
                                }

                                //Log.d("回應3", "");
                                //result.success(_sql_respround);
                                result.success(jsonArray.toString());


                            } catch (SQLException se) {
                                Log.e("ERROR-1", se.getMessage());
                                result.success(se.getMessage());
                            } catch (Exception e) {
                                Log.e("ERROR-3", e.getMessage());
                                Log.e("ERROR-3", e.getLocalizedMessage());

                                try {
                                    if(query_obj.getString("command").contains("nspRFLOTIDCheck_Json")) {
                                        result.success(e.getMessage() + "^" + _sql_respround);
                                    }
                                    else{
                                        result.success(e.getMessage());
                                    }
                                } catch (JSONException jsonException) {
                                    jsonException.printStackTrace();
                                    result.success(e.getMessage());
                                }
                            }


                        }







                        //int batteryLevel = getBatteryLevel();

                        /*
                        if (batteryLevel != -1) {
                            result.success(_sql_respround);
                        } else {
                            result.error("UNAVAILABLE", "Battery level not available.", null);
                        }

                         */

                        /*
                        if (call.method.equals("getBatteryLevel")) {


                            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder()
                                    .permitAll().build();
                            StrictMode.setThreadPolicy(policy);
                            Connection conn = null;
                            PreparedStatement cs=null;
                            String ConnURL;
                            ResultSet rs = null;
                            String _sql_respround=null;

                            try {//this for local ip, use ip or your pc name which has server (mssql 3031) in it
                                Log.d("成功", "this for local ip, use ip or your pc name which has server (mssql 3031) in it");
                                Class.forName("net.sourceforge.jtds.jdbc.Driver").newInstance();
                                conn = DriverManager.getConnection("jdbc:jtds:sqlserver://tjteck.com:5678/iWMS_YC;user=" + "rf" + ";password=" + "rf");
                                Log.d("成功", "this for local ip, use ip or your pc name which has server (mssql 3031) in it");


                                //String query = "exec nspRFLogin_Android_Json '{\"RFLoginData\": [ {\"userID\":\"david\",\"userPWD\":\"david\"}]}',1,1,1";
                                String query = "exec nspRFauthority_Android_Json '{\"RFauthorityData\": [ {\"userID\":\"David\"}]}',1,1,1";
                                Log.d("下命令", ""+query);
                                cs=conn.prepareStatement(query);
                                cs.setEscapeProcessing(true);
                                cs.setQueryTimeout(90);
                                rs = cs.executeQuery();
                                JSONArray json = new JSONArray();
                                ResultSetMetaData rsmd = rs.getMetaData();
                                while(rs.next()) {
                                    int numColumns = rsmd.getColumnCount();
                                    JSONObject obj = new JSONObject();
                                    for (int i=1; i<=numColumns; i++) {
                                        String column_name = rsmd.getColumnName(i);
                                        obj.put(column_name, rs.getObject(column_name));
                                        String s = rs.getString(column_name);
                                        Log.d("回應", ""+s);
                                        _sql_respround = s;
                                    }
                                    json.put(obj);
                                }






                            } catch (SQLException se) {
                                Log.e("ERROR", se.getMessage());
                            } catch (ClassNotFoundException e) {
                                Log.e("ERROR", e.getMessage());
                            } catch (Exception e) {
                                Log.e("ERROR", e.getMessage());
                            }


                            int batteryLevel = getBatteryLevel();

                            if (batteryLevel != -1) {
                                result.success(_sql_respround);
                            } else {
                                result.error("UNAVAILABLE", "Battery level not available.", null);
                            }
                        } else {
                            result.notImplemented();
                        }

                         */



                    }
                });
    }
    @Override
    public void onDestroy() {
        super.onDestroy();

        if (wakeLock != null && wakeLock.isHeld()) {
            wakeLock.release();
            Log.d("TTSService", "WakeLock 已釋放");
        }
    }

    private void enableImmersiveMode() {
        // Android R+ (API 30) 使用新版方式控制 UI
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            final WindowInsetsController insetsController = getWindow().getInsetsController();
            if (insetsController != null) {
                insetsController.hide(WindowInsets.Type.navigationBars());
                insetsController.setSystemBarsBehavior(
                        WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                );
            }
        } else {
            // 舊版裝置使用傳統 flags 控制
            final int flags = View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE;

            getWindow().getDecorView().setSystemUiVisibility(flags);
        }

        // 防止某些情況下系統列又回來，延遲重新套用 immersive mode
        handler.postDelayed(this::enableImmersiveMode, 3000); // 每 3 秒重套一次（可調整）
    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        return batteryLevel;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine engine) {
        super.configureFlutterEngine(engine);
        flutterEngine = engine;
    }

    public static void notifyFlutterComplete(String no) {
        if (flutterEngine != null) {
            new Handler(Looper.getMainLooper()).post(() -> {
                new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                        .invokeMethod("notifyNo", no);
            });
        }
    }

}

