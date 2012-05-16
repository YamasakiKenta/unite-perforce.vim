function! unite#kinds#k_p4_filelog#define()
	return s:kind
endfunction

" ********************************************************************************
" kind - k_p4_filelog
" ********************************************************************************
let s:kind = {
			\ 'name' : 'k_p4_filelog',
			\ 'default_action' : 'a_p4_print',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_print = {
			\ 'is_selectable' : 1, 
			\ }
function! s:kind.action_table.a_p4_print.func(candidates) "{{{
	for l:candidate in deepcopy(a:candidates)
		let name    = candidate.action__path
		
		let filetype_old = &filetype

		if exists('candidate.action__revnum')
			let revnum  = candidate.action__revnum
			" Vim だと、# を入れたらパスが表示される為、離脱文字が必要 
			call perforce#LogFile1(fnamemodify(name,':t').'\#'.revnum, 0) 
			let strs = perforce#pfcmds('print -q '.perforce#Get_kk(name."#".revnum))
		elseif exists('candidate.action__chnum')
			let chnum = candidate.action__chnum.low
			call perforce#LogFile1(fnamemodify(name,':t').'\@'.chnum, 0) 
			let strs = perforce#pfcmds('print -q '.perforce#Get_kk(name."@".chnum))
		endif

		" データの出力
		call append(0,strs) 
		exe 'setf' filetype_old

	endfor
endfunction "}}}
