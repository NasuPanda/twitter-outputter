// NOTE: require()の返り値がModuleで、Module.defaultの中にtwitter-textの実態がいる形。
const twitter = require('twitter-text').default;

const editingPost = document.getElementById("editing-post-content");
const charCountDown = document.getElementById("char-count-down");

editingPost.addEventListener("keyup", () => {
  const result = twitter.parseTweet(editingPost.value);
  // 日本語版の場合140文字制限(280バイト制限なのは変わらないが)なので、表示用に2で割る
  const jaWeightedLength = result.weightedLength / 2
  charCountDown.textContent = 140 - jaWeightedLength;
})