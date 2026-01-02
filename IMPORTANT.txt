# to change fields change code in pit_scout_form.dart and match_scout_form.dart
MAKE SURE THE LABEL OF EVERY FIELDS ARE SAME AS IN GOOGLE SHEETS

#to set google SHEETS
go to extention > appscripts and paste this following code


NOTE: Make sure you keep the same labels in this code too
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function doPost(e) {
  const logs = [];
  
  // Check if POST data exists
  if (!e.postData || !e.postData.contents) {
    logs.push("❌ No POST data received.");
    return ContentService.createTextOutput(logs.join("\n"));
  }

  logs.push("🔵 Raw postData: " + e.postData.contents);

  try {
    const body = JSON.parse(e.postData.contents);
    logs.push("✅ Parsed JSON:\n" + JSON.stringify(body, null, 2));

    // Require sheet name to be explicitly specified
    if (!body.sheet) {
      logs.push("❌ 'sheet' field is missing in request. Must be 'Pit Scout Data' or 'Match Scout Data'");
      return ContentService.createTextOutput(logs.join("\n"));
    }

    const sheetName = body.sheet;
    logs.push("📄 Target sheet: " + sheetName);

    // Verify data exists
    if (!body.data) {
      logs.push("❌ 'data' field is missing in request.");
      return ContentService.createTextOutput(logs.join("\n"));
    }

    const data = body.data;
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    let sheet = ss.getSheetByName(sheetName);

    // Create sheet if it doesn't exist
    if (!sheet) {
      sheet = ss.insertSheet(sheetName);
      logs.push("📝 Created new sheet: " + sheetName);
    }

    // Define column structure for each sheet
    const columns = {
      "Pit-Scout-Data-Raw": [
        "Team Number",
        "Autonomous strat",
        "Drivetrain",
        "Coral-Score-Level",
        "Coral-Intake",
        "Can Remove Algae From Reef?",
        "Can Score Algae In Processor?",
        "Can Score Algae In Barge?",
        "Endgame",
        "Additional Notes",
        "Time stamp",
        "Submitted by"
      ],
      "Match-Scout-Data-Raw": [
        "Team Number",
        "Match Number",
        "Start Position",
        "AUTO-moved?",
        "AUTO-L1",
        "AUTO-L2",
        "AUTO-L3",
        "AUTO-L4",
        "AUTO-remove-algae",
        "AUTO-processor",
        "AUTO-barge",
        "L1",
        "L2",
        "L3",
        "L4",
        "Remove-algae",
        "Processor",
        "Barge",
        "Endgame",
        "Drive team rating",
        "Defence rating",
        "Time stamp",
        "Submitted by"
      ]
    };

    // Check if sheet name is valid
    if (!columns[sheetName]) {
      logs.push("❌ Invalid sheet name. Must be 'Pit-Scout-Data-Raw' or 'Match-Scout-Data-Raw'");
      return ContentService.createTextOutput(logs.join("\n"));
    }
    

    // Prepare row data in correct column order
    const row = columns[sheetName].map(col => {
      const value = data[col];
      return Array.isArray(value) ? value.join(", ") : (value || "");
    });

    // Append data
    sheet.appendRow(row);
    logs.push("✅ Successfully appended data to " + sheetName);
    // Sort the sheet after appending

    sortSheet(sheet, sheetName);
    logs.push("🔃 Sheet sorted by Team Number" + (sheetName === "Match-Scout-Data-Raw" ? " and Match Number" : ""));

    return ContentService.createTextOutput(logs.join("\n"));

  } catch (err) {
    logs.push("❌ Exception: " + err.message);
    return ContentService.createTextOutput(logs.join("\n"));
  }
  
}

// Helper function to sort the sheet
function sortSheet(sheet, sheetName) {
  const lastRow = sheet.getLastRow();
  const lastCol = sheet.getLastColumn();
  
  if (lastRow <= 1) return; // No data to sort (only headers)
  
  const range = sheet.getRange(2, 1, lastRow - 1, lastCol); // Skip header row
  
  if (sheetName === "Pit-Scout-Data-Raw") {
    // Sort Pit Scout Data by Team Number (column 1)
    range.sort({ column: 1, ascending: true });
  } else if (sheetName === "Match-Scout-Data-Raw") {
    // Sort Match Scout Data by Team Number (column 1) → then Match Number (column 2)
    range.sort([
      { column: 1, ascending: true }, // Team Number
      { column: 2, ascending: true }  // Match Number
    ]);
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

after pasting click deploy > newdeployment > set deploy type to "Web App" > change access to everyone > hit deploy
*if getting authorization, authorize it, click advance setting and trust unsafe project*

copy the URL you get and paste it in "scanner_page.dart" around line 13 in the variable "final String scriptUrl"


****important****** 
 MAKE SURE ALL THE LABELS IN THE SHEET CODE, pit_scout_form, match_scout_form, and even inside the sheet 
are same, everything needs to be exact. and name your sheet  are nameed "Pit-Scout-Data-Raw" and "Match-Scout-Data-Raw" exactly
****important****** 


# to test the app on android phone, with a cord. turn on "developer mode" and enable "usb debugging"
see devices by running "flutter devices" command on terminal
use "flutter run" on terminal to run

# finally to build apk, run command "flutter build apk" on terminal
you can find the file in the app directory under build\app\outputs\flutter-apk\app-release.apk
now you can send it to devices and enjoy 