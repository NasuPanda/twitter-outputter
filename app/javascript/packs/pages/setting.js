function toDisabledColor(element) {
  element.classList.add("disabled-color");
}

function toEnabledColor(element) {
  element.classList.remove("disabled-color");
}

function toDisabled(element) {
  element.disabled = true
}

function toEnabled(element) {
  element.disabled = false
}

const canChangeColors = document.querySelectorAll(".can-change-color")
// HACK f.time_selectにclassを付与出来ないため無理やり取得
const forms = document.querySelectorAll(".can-change-color > select, input[type=number]")
const checkbox = document.querySelector(`input[type='checkbox']`)

checkbox.addEventListener("change", ()=> {
  if (checkbox.checked) {
    canChangeColors.forEach((element) => { toEnabledColor(element) });
    forms.forEach((form) => { toEnabled(form) })
  } else {
    canChangeColors.forEach((element) => { toDisabledColor(element) });
    forms.forEach((form) => { toDisabled(form) })
  }
})
