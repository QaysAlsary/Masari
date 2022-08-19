import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "masari-359822",
  "private_key_id": "0ebc67ef35c8ae5cb9df4c890f53182a6c502902",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCJxv12NKPSWKDK\naR2R+V9ZcDvZXNST07hONMDDtK5RvRR+SrE0TVc5x0y89azhis1UYIVKZVrmSNLc\n8aURhf73CgnOTvJee/xqxlF00XWTvbrM7+NpoczYLhRp8X7LIG5yAGdlD8K2Y3oc\ncR9I6dDzx+IaOF0pqRYFycbeKou9lTfxkzzZCza+GiWw4YgmaM1vG4hLNFKZINif\naY+OBA+swS/Z+pLjIm2kT1yxkwjjmNmd+PFc6FMctU5C5ojEWr67xecwPsDP7P5O\nHoP5iYdVH9pNnTarm3+jnabTQZShEadXA8myx3aZ+EVwqM8Dn+Uin6n/SZLfQHF9\nJDZlxvi5AgMBAAECggEAAhiZiAOu5M4vYPFndJkFeoHOVmb1F939Oo55rks16bga\n3eDJI++eZdNbc8vU0zgMqG94J6n8wVJBh+Q2XYViTc6hH3NzsYO+YTDQblOaIZvk\n85dWfcQV560sPKrUgdT0F2zqex0vGlay/PLJMI+C+84JaYUKyAaIBaFMoPaKoZoA\ndks/hYUHOfL6rSCpKul+ssVT5XOpr7jOjj5eEB69FzGvrFUKh/NUkizbjcU6QEbj\n9eNFccaGkJkLTzFEq85eTnEh4MZzriFmGHe+AVjZRfAEMfno17E6T4dvyW6em2v8\n1G3MGammHqqloDvtuCHtp2zZteI8SbEmMOBSpSRCeQKBgQDAQRHSjYtp5mF3JKg+\nkLw5tCHD7YYyr2B/0ySgelqzVDr/YgC3RVI9iHzkAkFWPm022wRz6stjicNg7Kjc\n50EOHH0ay+j0NsmGVIjc7vebHD8XeChRWS+o/w6wbb9K2a7fjT/wmoRKy6nFAC9S\nnJYG7CdjHO+tFHvMRgxdbunFjQKBgQC3dc+zrDKnNIdaO6iSiq1u3+10+Igagg1c\nBd+qLw6YzPLyADraLYvtl9qHalnHtlncuzFeuQ6DTi2BCgkoL5Dho9YL0fTioSnN\nDXBxrzd06f5pK7pwB5Zb/XmkVvDPxC483J5EwdQb0f1ZSTvkB9gRwiwoHPoKcPK/\ntitpnNam3QKBgDdeBf33WaEkAgnH+tQZ5rtPjzHX5AAQ1d+6NSAqXJist1j5Jm+h\nfS/PcPhRVfO6gsV7ierAQdbmw+fUAEWuK+QefEENXIeIh70x90B5acG3/suJhUL4\nRmuLGPXihWbPDje/fByUw2ivArODfB10jxhrRmSa3sOf1I9d1Q3LdXO5AoGAX9xL\nPxLHFN85qkhp+MhFfx26sdf7Jf62hFL9X6te8TCF8TV1ivMpnmguY3uKlfQOWGvn\njBseHjYHSNm5lynjhkNZYKvATXrwoJhZHM31KD3sFYAn1sngIwj7OofDJIzZrCuK\n91pgPnkm7DR7+taua/kNoZgifrot3UaOwIyXDHECgYEAkFiJgnIm5FYUzsaZ/Bv3\n+SxSKDovfNSB8SRqWJq9VAlE601uKRThMQED6tZmGlb3rSRmGkUR4svUEn6wB8bu\nno+1l8LrHf4Q7Llb4TatEiKSUsIPnDveZe7S05NXBJZFHSj+eP85YEd7j8HUHkiU\nftb8pzGGNxMg3h2BWHVjJTU=\n-----END PRIVATE KEY-----\n",
  "client_email": "masari@masari-359822.iam.gserviceaccount.com",
  "client_id": "111486718654596115788",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/masari%40masari-359822.iam.gserviceaccount.com"
}
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '12GJnBr8kbD_7lMb9ynFXC8pPgtFQlQTCbTMhfF3J5u4';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet?.values
        .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
      await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
      await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
      await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}