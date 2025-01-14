function openBugPage() {
  var bugNumber = document.getElementById('bugNumber').value;
  if (bugNumber.trim() === "") {
    alert("Please enter a bug number.");
    return;
  }

  var url = "https://bugs.launchpad.net/bugs/" + bugNumber;
  chrome.tabs.create({ url: url });
}

