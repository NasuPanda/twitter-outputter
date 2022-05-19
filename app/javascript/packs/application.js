require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Bootstrap導入
import "bootstrap"
import "bootstrap/scss/bootstrap.scss"
import "../stylesheets/application.scss"

// document.cookiesは "key=value;key2=value2..."という形式
function getExternalUserIdFromCookies(key) {
  const cookies = document.cookie;
  const cookiesArray = cookies.split(';');

  for(let cookie of cookiesArray){
      const keyValuePair = cookie.split('=');
      // cookieが"key=value; key=value2"のように空白を含む事があるのでtrim()しておく
      if( keyValuePair[0].trim() == key){
          return keyValuePair[1]
      }
  }
  return null
}

// TODO 余力があればfetchedExternalUserIdをメモ化する
OneSignal.push(function() {
  OneSignal.getExternalUserId().then(function(fetchedExternalUserId) {
    if (!fetchedExternalUserId) {
      const externalUserId = getExternalUserIdFromCookies("external_user_id")
      if (externalUserId) {
        OneSignal.push(function() {
          OneSignal.setExternalUserId(externalUserId)
          console.log("assign", externalUserId, "to external user id")
        })
      }
    }
  })
})
