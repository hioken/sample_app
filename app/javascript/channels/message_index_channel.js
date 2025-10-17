// サジェストリクエストと受取処理
// 受け取る時に、既にhiddenがあるならアラートして削除

const input = document.getElementById("user-search-input");
const suggestTemplate = document.getElementById("suggest-item-template");
const suggestContainer = document.getElementById("suggest-list");
let timerId;
let suggestClone;

function showSuggest(suggestList) {
  suggestContainer.textContent = '';
  for (const suggest of suggestList) {
    suggestClone = suggestTemplate.content.cloneNode(true);
    suggestClone.querySelector(".suggest-username").textContent = suggest[1];
    suggestClone.querySelector(".suggest-uid").textContent = suggest[0];
    suggestContainer.appendChild(suggestClone);
  }
}

async function getSuggest(word) {
  try {
    console.log('##### suggest request #####');
    const res = await fetch(`/suggest/${word}`, {method: 'GET'});
    console.log(res);
    const data = await res.json();
    console.log(data);
    showSuggest(data);
  } catch(err) {
    console.error('サジェストエラー', err);
    return null;
  }
}

input.addEventListener('input', () => {
  clearTimeout(timerId);
  if (input.value !== '' && input.value !== '@') {
    timerId = setTimeout(() => getSuggest(input.value), 498);
  }
})

suggestContainer.addEventListener('click', e => {
  const targetElement = e.target.closest('.suggest-item');
  if (targetElement) { input.value = targetElement.querySelector('.suggest-uid').textContent }
})