
" Fix files with prettier, and then ESLint.
let b:ale_linters = ['pyls', 'black', 'flake8', 'mypy', 'pylint', 'pyre', 'pydocstyle']
"let b:ale_linters = ['pyls', 'black', 'pylint', 'pydocstyle']
let b:ale_fixers = ['black', 'isort']

" complete imports
let b:ale_completion_autoimport = 1
