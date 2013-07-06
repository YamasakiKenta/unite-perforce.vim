let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* PfEdit   call perforce#command#edit_add(0, <f-args>)

command! -nargs=* PfAdd    call perforce#command#edit_add(1, <f-args>)

command! -nargs=? PfDiff   call perforce#diff#file(<f-args>)

command! -nargs=? PfRevert call perforce#command#revert(<f-args>)

command! -complete=customlist,perforce#command#complate_have -nargs=1 PfFind call perforce#pfFind(<f-args>)

command! PfSetting call perforce#data#setting()

command! PfAnnotate call perforce#command#annnotate(expand("%:p"))

command! -nargs=+ PfMatomeDiffs call perforce#matomeDiffs(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

