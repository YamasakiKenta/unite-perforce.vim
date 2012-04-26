if exists('g:loaded_unite_perforce')
	finish
endif

"çƒíËã`ñhé~
let g:loaded_unite_perforce = 1

"ê›íË
let g:pf_user_changes_only = 1
let g:pf_client_changes_only = 1
let g:PerforceDiff = 1
let g:pf_is_submit_flg = 1
let g:pf_is_out_flg = 1
let g:pf_is_echo_flg = 1
let g:pf_is_vimdiff_flg = 0
let g:pf_diff_tool = 'WinMergeU '
let g:ClientMove_recursive_flg = 0
let g:ClientMove_defoult_root = 'c:\tmp'

"global
let g:G_PF_CLIENT = 1
let g:G_PF_PORT   = 2
let g:G_PF_USER   = 4
let g:G_PF_CHANGE = 8
