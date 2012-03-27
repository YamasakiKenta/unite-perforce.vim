map ;up<CR> :<C-u>Unite source -input=p4<CR>|"
map ;wd<CR> :<C-u>call perforce#pfDiff(expand("%"))<CR>|"  

map ;cl<CR> :<C-u>echo $PFCLIENTNAME . " - " . $PFCLIENTPATH<CR>|"

map ;pi<CR> :<C-u>call okazu#LogFile('p4log',perforce#cmds('info'))<CR>|"
map ;pe<CR> :<C-u>call okazu#LogFile('p4log')<CR>:r!p4 edit "<C-r>t"<CR>|"

map ;pt<CR> :<C-u>Unite p4_clients<CR>|"
map ;pc<CR> :<C-u>Unite p4_changes_pending<CR>|"
map ;ps<CR> :<C-u>Unite p4_changes_submitted<CR>|"
map ;po<CR> :<C-u>Unite p4_opened<CR>|"
map ;pj<CR> :<C-u>Unite p4_jobs<CR>|"

map ;ph<CR> :<C-u>Unite p4_have<CR>|"
map ;ff<CR> :<C-u>call perforce#pfFind()<CR>|"
map ;pa<CR> :<C-u>Unite p4_annotate<CR>|"

map ;pl<CR> :<C-u>call perforce#unite_args('p4_filelog')<CR>|"
map ;pd<CR> :<C-u>call perforce#unite_args('p4_diff')<CR>|"
