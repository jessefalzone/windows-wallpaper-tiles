function track(event) {
  const select = document.getElementById('backgroundSelect');
  const total = select.options.length;
  let newIndex;
  if (event.currentTarget.id === 'prev') {
    newIndex = --select.selectedIndex < 0 ? total - 1 : select.selectedIndex;
  } else {
    newIndex = ++select.selectedIndex === total ? 0 : select.selectedIndex;
  }
  select.selectedIndex = newIndex;
}

(function main() {
  document.getElementById('prev').addEventListener('click', track);
  document.getElementById('next').addEventListener('click', track);
})();
