let g:ale_rust_rls_toolchain = 'stable'

" Fix files with prettier, and then ESLint.
let b:ale_linters = ['cargo', 'rls', 'rustc']
let b:ale_fixers = ['rustfmt']
let b:ale_rust_rls_config = {'rust': {'clippy_preference': 'on'}}

