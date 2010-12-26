$(function() {
  var maxCommits = 3;
  var apiUrl = "http://github.com/api/v2/json/commits/list/inca/circumflex";
  var activitySection = $("#gh-activity");
  if (activitySection) {
    var commitTemplate = $("#gh-commit-tmpl");
    // replace with loading image
    var placeholder = $('<img src="/img/loading.gif"/>');
    activitySection.replaceWith(placeholder);
    // retrieve refspec for github
    var refspec = $("a", activitySection).text();
    var url = apiUrl + "/" + refspec;
    // go to GitHub for commit data
    $.get(url, {}, function(data) {
      var i = 0;
      maxCommits = data.commits.length < maxCommits ? data.commits.length : maxCommits;
      var commitsList = $('<ul id="gh-commits"/>');
      for (i = 0; i < maxCommits; i++) {
        var commit = data.commits[i];
        var emailHash = $.md5(commit.author.email);
        var commitDate = new Date(Date.parse(commit.committed_date)).toDateString();
        var listItem = commitTemplate.tmpl({ "commit": commit, "emailHash": emailHash, "commitDate": commitDate});
        commitsList.append(listItem);
      }
      placeholder.replaceWith(commitsList);
    }, "jsonp");
  }
});