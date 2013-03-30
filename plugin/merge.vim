let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? PfMerge call perforce_2#pf_merge(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

