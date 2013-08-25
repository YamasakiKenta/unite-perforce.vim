let s:save_cpo = &cpo
set cpo&vim

function! s:get_change_num_from_changes(str) 
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction

function! pf_changes#get(context,data_ds)  "{{{
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
						\ 'action__chnum'  : s:get_change_num_from_changes(out),
						\ 'action__client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ 'action__out'    : out,
						\ })
		endfor
	endfor

	return candidates
endfunction
"}}}
function! pf_changes#gather_candidates(args, context, status)  "{{{
	" ********************************************************************************
	" チェンジリストの表示 表示設定関数
	" チェンジリストの変更の場合、開いたいるファイルを変更するか、actionで指定したファイル
	" @param[in]	args				depot
	" ********************************************************************************
	"
	" 表示するクライアント名の取得
	let datas = []
	if a:context.source__client_flg == 1
		let datas = a:context.source__client
	endif


	let clients          = call('perforce#get#clients#get_args_clients'     , datas)
	let ports            = call('perforce#get#clients#get_ports'            , datas)
	let use_port_clients = call('perforce#get#clients#get_use_port_clients' , datas)

	call s:get_port_clients(use_port_clients)

	" defaultの表示
	let candidates = []

	if a:status == 'pending'
		call extend(candidates, map( copy(use_port_clients), "{
					\ 'word'           : 'default by '.v:val,
					\ 'action__chnum'  : 'default',
					\ 'action__client' : v:val,
					\ 'action__depots' : a:context.source__depots,
					\ }"))
	endif

	let users   = perforce#data#get_users()
	let max     = perforce#data#get_max()

	for client in clients
		for user in users
			let cmd     = 'p4 changes '.user.''.client.''.max.'-s '.a:status
			let data_ds = perforce#cmd#clients(ports, cmd)
			call extend(candidates, pf_changes#get(a:context, data_ds))
		endfor
	endfor

	return candidates
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
		let clients = s:get_port_clients()
		for client in clients
			call add(candidates, {
						\ 'word'           : '[new] '.client.'     : '.newfile,
						\ 'kind'           : 'k_p4_change_reopen',
						\ 'action__chname' : newfile,
						\ 'action__chnum'  : 'new',
						\ 'action__client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ })
		endfor
	endif

	return candidates

endfunction
"}}}

function! pf_changes#make(strs, port_client, ...) "{{{
	"********************************************************************************
	" チェンジリストの作成
	" @param[in]	str		チェンジリストのコメント
	" @param[in]	...		編集するチェンジリスト番号
	" @param[out]	chnum	作成したチェンジリスト
	"********************************************************************************
	"
	let strs = (type(a:strs)==type([])) ? a:strs : [a:strs]

	"チェンジ番号のセット ( 引数があるか )
	let chnum     = get(a:,'1','')

	"ChangeListの設定データを一時保存する
	let cmd = 'p4 change -o '.chnum
	let tmp = perforce#system('p4 '.a:port_client. ' change -o '.chnum)

	" 新規作成の場合は、ファイルを含まない
	if chnum == "" 
		let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') 
	endif

	"コメントの編集
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\n\w\+:\|$\)','','') 

	let outs = split(tmp, "\n")
	let i = 0

	while(outs[i]) !~ '^Description:'
		let i = i + 1
	endwhile

	call map(strs, "' '.v:val")
	let outs = extend(outs, strs, i+1)

	"一時ファイルの書き出し
	let temp_file = tempname()
	call writefile(outs,temp_file) 

	" チェンジリストの作成
	let cmd   = 'more '.perforce#get_kk(temp_file()).' | p4 '.a:port_client.' change -i'
	let outs   = split(perforce#system(cmd), "\n")
	let chnum = matchstr(outs[0], '\d\+')

	return chnum

endfunction
"}}}
" === kind ===

let s:port_clients = perforce#get#clients#get_use_port_clients()
function! s:get_port_clients(...) "{{{
	if exists('a:1')
		let s:port_clients = a:1
	endif
	return s:port_clients
endfunction
"}}}

function! s:get_client_from_change(candidate) 
	return matchstr(a:candidate.action__out, '@\zs\w*')
endfunction
function! pf_changes#get_port_client(candidate)  "{{{
	let port_client = a:candidate.action__client

	if port_client !~ '-c'
		let client = s:get_client_from_change(a:candidate)
		let port_client = port_client.' -c '.client
	endif

	return port_client
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
