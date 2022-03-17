import 'package:epikwallet/localstring/resstringid.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthUtils {
  /// 本地认证框架
  static final LocalAuthentication auth = LocalAuthentication();

  /// 是否有可用的生物识别技术
  static bool _canCheckBiometrics = false;

  /// 生物识别技术列表
  static List<BiometricType> _availableBiometrics = [];

  /// 设备是否支持touch 或者 face 验证
  static Future<bool> checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      print(e);
    }
    _canCheckBiometrics = canCheckBiometrics;
    return _canCheckBiometrics;
  }

  static bool get canBiometrics{
   return _canCheckBiometrics??false;
  }

  static  List<BiometricType> get availableBiometrics{
    return _availableBiometrics??[];
  }

  /// 获取生物识别技术列表
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    _availableBiometrics = availableBiometrics;
    return _availableBiometrics;
  }

  //return true成功 false取消 null认证失败
  static Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      // print("availableBiometrics = $availableBiometrics");

      // if (Platform.isIOS) {
      //   if (availableBiometrics.contains(BiometricType.face)) {
      //     // Face ID.
      //   } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      //     // Touch ID.
      //   }
      // }
      // isAuthenticated = await auth.authenticateWithBiometrics(
      //   localizedReason: "用于快速登录",
      //   //'生物识别快速登录',
      //   useErrorDialogs: true,
      //   stickyAuth: true,
      //   androidAuthStrings: getAndroidAuthMessages(),
      //   iOSAuthStrings: getIOSAuthMessages(),
      // );

      authenticated = await auth.authenticate(
        localizedReason: RSID.biometrics_localizedReason.text,
        //'Scan your fingerprint (or face or whatever) to authenticate',
        useErrorDialogs: true,
        stickyAuth: true,
        biometricOnly: true,//只使用生物识别
          // sensitiveTransaction: true,
        androidAuthStrings: getAndroidAuthMessages(),
        iOSAuthStrings: getIOSAuthMessages(),
      );

      // print("isAuthenticated = " + authenticated.toString());
    } on PlatformException catch (e,s) {
      print("authenticate error PlatformException");
      // PlatformException(LockedOut, The operation was canceled because the API is locked out due to too many attempts. This occurs after 5 failed attempts, and lasts for 30 seconds., null, null)
      print(e);
      print(s);
      return null;
    } catch (e,s) {
      print("authenticate error");
      print(e);
      print(s);
      return null;
    }
    return authenticated;
  }

  static AndroidAuthMessages getAndroidAuthMessages() {
    return  AndroidAuthMessages(
      signInTitle: RSID.biometrics_signInTitle.text,//"身份验证", //Authentication Required
      biometricHint:  RSID.biometrics_biometricHint.text,//"请扫描指纹或面部",//Scan your fingerprint (or face or whatever) to authenticate
      biometricNotRecognized: RSID.biometrics_biometricNotRecognized.text,// "验证失败, 再试一次。",//"Not recognized, try again.",
      biometricSuccess: RSID.biometrics_biometricSuccess.text,// "验证成功",//"Success"
      cancelButton: RSID.biometrics_cancelButton.text,// "取消", //"Cancel"

      biometricRequiredTitle:  RSID.biometrics_biometricRequiredTitle.text,//"验证要求", //"Biometric required",
      goToSettingsButton: RSID.biometrics_goToSettingsButton.text,// "去设置", //"Go to settings",
      goToSettingsDescription: RSID.biometrics_goToSettingsDescription.text,// "您的设备没有开启此功能, 请到\"设置 > 安全\"中设置。", //Biometric authentication is not set up on your device. Go to \'Settings > Security\' to add biometric authentication.
    );
  }

  static IOSAuthMessages getIOSAuthMessages() {
    return  IOSAuthMessages(
      lockOut:  RSID.biometrics_ioslockOut.text,//"生物认证被禁用。请锁定再解锁您的屏幕启用它。", //'Biometric authentication is disabled. Please lock and unlock your screen to enable it.',
      goToSettingsButton:  RSID.biometrics_iosgoToSettingsButton.text,//"去设置",//"Go to settings",
      goToSettingsDescription:  RSID.biometrics_iosgoToSettingsDescription.text,//"您的设备上没有设置生物认证。请在您的手机上启用Touch ID或Face ID。", //'Biometric authentication is not set up on your device. Please either enable Touch ID or Face ID on your phone.',
      cancelButton: RSID.biometrics_cancelButton.text,//"好的", // "OK",
    );
  }
}
