let s:save_cpo = &cpo
set cpo&vim

command! -complete=customlist,perforce_2#complate_have -nargs=1 PfFind call perforce#pfFind(<f-args>)

command! -nargs=+ MatomeDiffs call perforce#matomeDiffs(<f-args>)

command! GetClientName call perforce#get_client_data_from_info()

command! -narg=* PfEdit call perforce_2#edit_add(0, <f-args>)
command! -narg=* PfAdd call perforce_2#edit_add(1, <f-args>)
command! -narg=* PfAdd call perforce_2#edit_add(1, <f-args>)
command! -narg=? PfDiff call perforce_2#pfDiff(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

