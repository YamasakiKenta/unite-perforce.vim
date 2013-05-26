let s:save_cpo = &cpo
set cpo&vim

function! s:get_ChangeNum_from_changes(str) 
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction

function! pf_changes#get(context,data_ds) 
	" ********************************************************************************
	" @par          p4_changes Untie 用の 返り値を返す
	" @param[in]	context
	" @param[in]	data_ds
	" ********************************************************************************
	let candidates = []
	for data_d in a:data_ds
		let client = data_d.client
		for out in data_d.outs
			call add( candidates, {
						\ 'word'           : client.' : '.out,
						\ 'action__chnum'  : s:get_ChangeNum_from_changes(out),
						\ 'action__client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ })
		endfor
	endfor

	return candidates
endfunction

function! pf_changes#gather_candidates(args, context)  "{{{
	" ********************************************************************************
	" チェンジリストの表示 表示設定関数
	" チェンジリストの変更の場合、開いたいるファイルを変更するか、actionで指定したファイル
	" @param[in]	args				depot
	" ********************************************************************************
	"
	" 表示するクライアント名の取得
	let clients = perforce#data#get('g:unite_perforce_clients')

	" defaultの表示
	let rtn = []
	let rtn += map( clients, "{
				\ 'word'           : 'default by '.v:val,
				\ 'kind'           : 'k_p4_change_pending',
				\ 'action__chnum'  : 'default',
				\ 'action__client' : v:val,
				\ 'action__depots' : a:context.source__depots,
				\ }")

	let data_ds = perforce#cmd#new('changes','','-s pending')
	let rtn += pf_changes#get(a:context, data_ds)
	return rtn
endfunction
"}}}
function! pf_changes#change_candidates(args, context)  "{{{
	" ********************************************************************************
	" p4 change ソースの 変化関数
	" @param[in]	
	" @retval       
	" ********************************************************************************
	" Unite で入力された文字
	let newfile = a:context.input
	let candidates = []

	" 入力がない場合は、表示しない
	if newfile != ""
		let clients = perforce#data#get('g:unite_perforce_clients')
		for client in clients
			call add(candidates, {
						\ 'word' : '[new] '.client.' : '.newfile,
						\ 'kind' : 'k_p4_change_reopen',
						\ 'action__chname' : newfile,
						\ 'action__chnum' : 'new',
						\ 'action_client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ })
		endfor
	endif

	return candidates

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
