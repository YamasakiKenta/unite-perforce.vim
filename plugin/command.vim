let s:save_cpo = &cpo
set cpo&vim

command! -complete=customlist,perforce_2#complate_have -nargs=1 PfFind call perforce#pfFind(<f-args>)

command! PfSetting call perforce#data#setting()

command! -nargs=+ PfMatomeDiffs call perforce#matomeDiffs(<f-args>)

command! -nargs=* PfEdit   call perforce_2#edit_add(0, <f-args>)

command! -nargs=* PfAdd    call perforce_2#edit_add(1, <f-args>)

command! -nargs=? PfDiff   call perforce#diff#files(<f-args>)

command! -nargs=? PfRevert call perforce_2#revert(<f-args>)

command! -nargs=? PfMerge call perforce_2#pf_merge(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

