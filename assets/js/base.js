document.querySelectorAll('.alert').forEach(function(elm) {
	elm.addEventListener('click', function(ev) {
		ev.target.classList.add('hidden');
	}, false);
});
