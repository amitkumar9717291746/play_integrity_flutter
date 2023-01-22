class PlayIntegrity {
  final RequestDetails? requestDetails;
  final AppIntegrity? appIntegrity;
  final DeviceIntegrity? deviceIntegrity;
  final AccountDetails? accountDetails;

  PlayIntegrity({
    this.requestDetails,
    this.appIntegrity,
    this.deviceIntegrity,
    this.accountDetails,
  });

  factory PlayIntegrity.fromJson(Map<String, dynamic> json) {
    return PlayIntegrity(
      requestDetails: RequestDetails.fromJson(json['requestDetails']),
      appIntegrity: AppIntegrity.fromJson(json['appIntegrity']),
      deviceIntegrity: DeviceIntegrity.fromJson(json['deviceIntegrity']),
      accountDetails: AccountDetails.fromJson(json['accountDetails']),
    );
  }
}

class RequestDetails {
  final String? requestPackageName, nonce;
  final int? timestampMillis;

  RequestDetails({
    this.requestPackageName,
    this.nonce,
    this.timestampMillis,
  });

  factory RequestDetails.fromJson(Map<String, dynamic> json) {
    return RequestDetails(
      requestPackageName: json['requestPackageName'].toString(),
      nonce: json['nonce'].toString(),
      timestampMillis: json['timestampMillis'] as int,
    );
  }
}

class AppIntegrity {
  final String? appRecognitionVerdict, packageName;
  final List<String>? certificateSha256Digest;
  final int? versionCode;

  AppIntegrity({
    this.appRecognitionVerdict,
    this.packageName,
    this.certificateSha256Digest,
    this.versionCode,
  });

  factory AppIntegrity.fromJson(Map<String, dynamic> json) {
    return AppIntegrity(
      appRecognitionVerdict: json['appRecognitionVerdict'].toString(),
      packageName: json['packageName'].toString(),
      certificateSha256Digest: json['certificateSha256Digest'] as List<String>,
      versionCode: json['versionCode'] as int,
    );
  }
}

class DeviceIntegrity {
  final List<String>? deviceRecognitionVerdict;

  DeviceIntegrity({
    this.deviceRecognitionVerdict,
  });

  factory DeviceIntegrity.fromJson(Map<String, dynamic> json) {
    return DeviceIntegrity(
      deviceRecognitionVerdict:
          json['deviceRecognitionVerdict'] as List<String>,
    );
  }
}

class AccountDetails {
  final String? appLicensingVerdict;

  AccountDetails({
    this.appLicensingVerdict,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(
      appLicensingVerdict: json['appLicensingVerdict'].toString(),
    );
  }
}
