// - - - - - - - - - - - - - - - - - -
// Twitter文字数制限の制御
// - - - - - - - - - - - - - - - - - -
// 装飾用クラス
const VALID_TEXTAREA_CLASS = "textarea-valid";
const INVALID_TEXTAREA_CLASS = "textarea-invalid";
const INVALID_TEXT_CLASS = "text-invalid";

// 操作する要素
const editingPost = document.getElementById("editing-post-content");
const charCountDown = document.getElementById("char-count-down");
const submitButtons = document.querySelectorAll("div#post-form-submit-container > button");
const submitLinks = document.querySelectorAll("div#post-form-submit-container > a");

// twitter-text
// NOTE: require()の返り値がModuleで、Module.defaultの中にtwitter-textの実態がいる形。
const twitter = require('twitter-text').default;

// カウント対象のHTML要素が持つテキストを結合する
function concatElementTexts(elements) {
  let result = "";
  elements.forEach((e) => {
    // <textarea>の場合
    if (e.tagName === "TEXTAREA") {
      text = e.value;
    // <li>の場合(タグの場合)
    } else if (e.tagName === "LI") {
      // textContentに含まれる空白・改行・タブを削除する
      text = e.textContent.replace(/\s+/g, '');
      // NOTE: タグの前には半角空白を入れるため, カウントにも反映させる
      text += ' '
    }
    result += text;
  });
  return result;
}

// 残り入力可能な文字数を表示する
function updateCharCountDown(jaWeightedLength) {
  const numberOfCharCanBeEntered = 140 - jaWeightedLength;
  charCountDown.textContent = numberOfCharCanBeEntered
}

// 入力文字数のバリデーション
function validateInputCharCount(jaWeightedLength, isValid) {
  // 有効な時 または テキストが入力されていない時
  if (isValid || jaWeightedLength == 0) {
    addAndRemoveClass(editingPost, VALID_TEXTAREA_CLASS, INVALID_TEXTAREA_CLASS);
    charCountDown.classList.remove(INVALID_TEXT_CLASS);
    submitButtons.forEach((e) => { e.disabled = false; });
    submitLinks.forEach((e) => { e.classList.remove("disable-link"); });
  // 無効な時
  } else {
    addAndRemoveClass(editingPost, INVALID_TEXTAREA_CLASS, VALID_TEXTAREA_CLASS);
    charCountDown.classList.add(INVALID_TEXT_CLASS);
    submitButtons.forEach((e) => { e.disabled = true });
    submitLinks.forEach((e) => { e.classList.add("disable-link"); });
  }
}

// 装飾用classをadd&removeする
function addAndRemoveClass(el, clsToBeAdd, clsToBeRemove) {
  el.classList.remove(clsToBeRemove)
  el.classList.add(clsToBeAdd)
}

// イベント本体
function updateAndValidateCharCount() {
  const countableTextAreas = document.querySelectorAll(".for-char-count");
  const total = concatElementTexts(countableTextAreas);
  const result = twitter.parseTweet(total);
  // 日本語版の場合140文字制限(280バイト制限なのは変わらないが)なので、表示用に2で割る
  const jaWeightedLength = result.weightedLength / 2
  const isValid = result.valid;

  updateCharCountDown(jaWeightedLength);
  validateInputCharCount(jaWeightedLength, isValid);
}

editingPost.addEventListener("input", updateAndValidateCharCount);
window.addEventListener("load", updateAndValidateCharCount);

// - - - - - - - - - - - - - - - - - -
// Textareaの長さを入力に応じて変化させる
// - - - - - - - - - - - - - - - - - -
function flexTextarea(el) {
  const dummy = el.querySelector('.flex-textarea-dummy')
  el.querySelector('.flex-textarea').addEventListener('input', e => {
    dummy.textContent = e.target.value + '\u200b'
  })
}

document.querySelectorAll('.flex-textarea-container').forEach(flexTextarea)
