chrome.omnibox.onInputEntered.addListener(function(text) {
  var bugNumber = text.substring(3);
  if (bugNumber.trim() === "") {
    alert("Please enter a bug number.");
    return;
  }

  var url = "https://bugs.launchpad.net/bugs/" + bugNumber;
  chrome.tabs.create({ url: url });
});

