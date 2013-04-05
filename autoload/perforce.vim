let s:save_cpo = &cpo
set cpo&vim

let $PFTMP     = expand( exists('$PFTMP') ? $PFTMP : '~/.perforce/' )
let $PFTMPFILE = $PFTMP.'/tmpfile'
if !isdirectory($PFTMP) | call mkdir($PFTMP) | endif

let s:L = vital#of('unite-perforce.vim')
let s:Common   = s:L.import('Mind.Common')
let s:Perforce = s:L.import('Mind.Perforce')

function! s:get_dd(str) "{{{
	return len(a:str) ? '//...'.perforce#common#get_kk(a:str).'...' : ''
endfunction "}}}
function! s:get_depot_from_where(str) "{{{
	return s:get_split_from_where(a:str, 1)
endfunction "}}}
function! s:get_depots(args, path) "{{{
	" ********************************************************************************
	" depots を取得する
	" @param[in]	args	ファイル名
	" @param[in]	context
	" ********************************************************************************
	if len(a:args) > 0
		let depots = a:args
	else
		let depots = [a:path]
	endif
	return depots
endfunction "}}}
function! s:get_path_from_have(str) "{{{
	let rtn = matchstr(a:str,'.\{-}#\d\+ - \zs.*')
	let rtn = substitute(rtn, '\\', '/', 'g')
	return rtn
endfunction "}}}
function! s:get_path_from_where(str) "{{{
	return matchstr(a:str, '.\{-}\zs\w*:.*\ze\n.*')
endfunction "}}}
function! s:get_paths_from_fname(str) "{{{
	" ファイルを検索
	let outs = perforce#pfcmds('have','',s:get_dd(a:str)).outs " # ファイル名の取得
	return s:get_paths_from_haves(outs)                   " # ヒットした場合
endfunction "}}}
function! s:get_paths_from_haves(strs) "{{{
	return map(a:strs,"s:get_path_from_have(v:val)")
endfunction "}}}
function! s:get_split_from_where(str,...) "{{{
	return split(a:str, '[^\\]\zs ')[1]
endfunction "}}}
function! s:is_p4_have_from_have(str) "{{{

	if a:str =~ '- file(s) not on client.'
		let flg = 0
	else
		let flg = 1
	endif

	return flg

endfunction "}}}
function! s:pf_diff_tool(file,file2) "{{{
	if perforce#data#get('is_vimdiff_flg')
		" タブで新しいファイルを開く
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diffの開始
		windo diffthis

		" キーマップの登録
		call s:Common.map_diff()
	else
		let cmd = perforce#data#get('diff_tool')

		if cmd =~ 'kdiff3'
			call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2).' -o '.perforce#common#Get_kk(a:file2))
		else
			" winmergeu
			call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2))
		endif
	endif
endfunction "}}}
function! s:pfdiff_from_fname(fname) "{{{
	" ********************************************************************************
	" perforceないからファイル名から検索して、全て比較
	" @param[in]	fname	比較したいファイル名
	" ********************************************************************************
	"
	" ファイル名のみの取出し
	let file = fnamemodify(a:fname,":t")

	let paths = s:get_paths_from_fname(file)

	call perforce#LogFile(paths)
	for path in paths 
		call perforce#pfDiff(path)
	endfor
endfunction "}}}

function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" 結果の出力を行う
	" @param[in]	str		表示する文字
	" ********************************************************************************

	if perforce#data#get('is_out_flg', 'common') == 1
		if perforce#data#get('is_out_echo_flg') == 1

			let strs = type(a:str) == type([]) ? a:str :[a:str]

			for str in strs
				echo str
			endfor

		else
			call perforce#common#LogFile('p4log', 0, a:str)
		endif
	endif


endfunction "}}}
function! s:get_ChangeNum_from_changes(str) "{{{
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction "}}}
function! perforce#get_ClientName_from_client(str) "{{{
	return matchstr(a:str,'Client \zs\S\+')
endfunction "}}}
function! perforce#get_ClientPathFromName(str) "{{{
	let str = system('p4 clients | grep '.a:str) " # ref 直接データをもらう方法はないかな
	let path = matchstr(str,'.* \d\d\d\d/\d\d/\d\d root \zs\S*')
	let path = perforce#common#get_pathSrash(path)
	return path
endfunction "}}}
function! perforce#get_PFCLIENTPATH(...) "{{{
	return call(s:Perforce.get_client_root, a:000)
endfunction "}}}
function! perforce#get_PFCLIENTNAME() "{{{
	return perforce#get_set_data('P4CLIENT')
endfunction "}}}
function! perforce#get_PFPORT() "{{{
	return perforce#get_set_data('P4PORT')
endfunction "}}}
function! perforce#get_PFUSER() "{{{
	return perforce#get_set_data('P4USER')
endfunction "}}}
function! s:system(cmd) "{{{
	if exists('s:exists_vimproc')
		let data = vimproc#system(a:cmd)
	else
		let data = system(a:cmd)
	endif
	return data
endfunction "}}}
function! perforce#get_set_data(str) "{{{
	return matchstr(s:system('p4 set '.a:str), '\w*=\zs.* \ze(set)')
endfunction "}}}
function! perforce#get_depot_from_have(str) "{{{
	return matchstr(a:str,'.\{-}\ze#\d\+ - .*')
endfunction "}}}
function! perforce#get_depot_from_opened(str) "{{{
	return substitute(a:str,'#.*','','')   " # リビジョン番号の削除
endfunction "}}}
function! perforce#get_depot_from_path(str) "{{{
	let out = split(system('p4 where "'.a:str.'"'), "\n")[0]
	let depot =  s:get_depot_from_where(out)
	return depot 
endfunction "}}}
function! perforce#get_filename_for_unite(args, context) "{{{
	" ファイル名の取得
	let a:context.source__path = expand('%:p')
	let a:context.source__linenr = line('.')
	let a:context.source__depots = s:get_depots(a:args, a:context.source__path)
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction "}}}
function! perforce#get_path_from_depot(depot) "{{{
	let out = system('p4 where "'.a:depot.'"')
	let path = s:get_path_from_where(out)
	return path
endfunction "}}}
function! perforce#get_pfchanges(context,outs,kind) "{{{
	" ********************************************************************************
	" p4_changes Untie 用の 返り値を返す
	" @param(in)	context	
	" @param(in)	outs
	" @param(in)	kind	
	" ********************************************************************************
	let outs = a:outs
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : a:kind,
				\ 'action__chnum' : s:get_ChangeNum_from_changes(v:val),
				\ 'action__depots' : a:context.source__depots,
				\ }")


	return candidates
endfunction "}}}
function! perforce#get_source_file_from_path(path) "{{{
	" ********************************************************************************
	" 差分の出力を、Uniteのjump_list化けする
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let path = a:path
	let lines = readfile(path)
	let candidates = []
	let lnum = 1
	for line in lines
		let candidates += [{
					\ 'word' : lnum.' : '.line,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : path,
					\ 'action__text' : line,
					\ }]
		let lnum += 1
	endfor
	return candidates
endfunction "}}}
function! perforce#init() "{{{

	" クライアントデータの読み込み
	call perforce#get_PFCLIENTPATH()

	" 設定の取得
	call perforce#data#init()
endfunction "}}}
function! perforce#is_p4_have(str) "{{{
	" ********************************************************************************
	" クライアントにファイルがあるか調べる
	" @param[in]	str				ファイル名 , have の返り値
	" @retval       flg		TRUE 	存在する
	" @retval       flg		FLASE 	存在しない
	" ********************************************************************************
	let str = system('p4 have '.perforce#common#get_kk(a:str))
	let flg = s:is_p4_have_from_have(str)
	return flg
endfunction "}}}
function! perforce#matomeDiffs(...) "{{{
	" new file 用にここで初期化
	let datas = []

	echo a:000
	for chnum in a:000
		" データの取得 {{{
		let outs = perforce#pfcmds('describe -ds','',chnum).outs

		" 作業中のファイル
		if outs[0] =~ '\*pending\*' || chnum == 'default'
			let files = perforce#pfcmds('opened','','-c '.chnum).outs
			call map(files, "perforce#get_depot_from_opened(v:val)")

			let outs = []
			for file in files 
				let list_tmps = perforce#pfcmds('diff -ds','',file).outs

				for list_tmp in list_tmps
					if list_tmp =~ '- file(s) not opened for edit.'
						let file_tmp = substitute(file, '.*[\/]','','')
						let path = perforce#get_path_from_depot(file)
						let datas += [{'files' : file_tmp, 'adds' : len(readfile(path)), 'changeds' : 0, 'deleteds' : 0, }]
					else
						let outs += [list_tmp]
					endif
				endfor
			endfor


		endif

		let find = ' \(\d\+\) chunks \(\|\(\d\+\) / \)\(\d\+\) lines'
		for out in outs
			if out =~ "===="
				let datas += [{'files' : substitute(out,'.*/\(.\{-}\)#.*','\1',''), 'adds' : 0, 'changeds' : 0, 'deleteds' : 0, }]
			elseif out =~ 'add'.find
				let datas[-1].adds = substitute(out,'add'.find,'\4','')
			elseif out =~ 'deleted'.find
				let datas[-1].deleteds = substitute(out,'deleted'.find,'\4','')
			elseif out =~ 'changed'.find
				let a = substitute(out,'changed'.find,'\3','')
				let b = substitute(out,'changed'.find,'\4','')
				let datas[-1].changeds = a > b ? a : b
			endif
		endfor
	endfor
	"}}}
	"
	"データの出力 {{{
	let outs = []
	for data in datas 
		let outs += [data["files"]."\t\t".data["adds"]."\t".data["deleteds"]."\t".data["changeds"]]
	endfor

	call perforce#common#LogFile('p4log', 0, outs)
	"}}}
endfunction "}}}
function! perforce#pfChange(str,...) "{{{
	"********************************************************************************
	" チェンジリストの作成
	" @param[in]	str		チェンジリストのコメント
	" @param[in]	...		編集するチェンジリスト番号
	"********************************************************************************
	"
	"チェンジ番号のセット ( 引数があるか )
	let chnum     = get(a:,'1','')

	"ChangeListの設定データを一時保存する
	let tmp = system('p4 change -o '.chnum)                          

	"コメントの編集
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\nFiles:\)\?','\t'.a:str.'\n','') 

	" 新規作成の場合は、ファイルを含まない
	if chnum == "" | let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') | endif

	"一時ファイルの書き出し
	call writefile(split(tmp,'\n'),$PFTMPFILE)

	" チェンジリストの作成
	" ★ client に対応する
	let out = split(system('more '.perforce#common#get_kk($PFTMPFILE).' | p4 change -i', '\n'))

	return out

endfunction "}}}
function! perforce#pfDiff(path) "{{{
	" ********************************************************************************
	" ファイルをTOOLを使用して比較します
	" @param[in]	path		比較するパス ( path or depot )
	" ********************************************************************************

	" ファイルの比較
	let path = a:path

	" 最新 REV のファイルの取得 "{{{
	let outs = perforce#pfcmds('print','',' -q '.perforce#common#get_kk(path)).outs

	" エラーが発生したらファイルを検索して、すべてと比較 ( 再帰 )
	if outs[0] =~ "is not under client's root "
		call s:pfdiff_from_fname(path)
		return
	endif

	"tmpファイルの書き出し
	call writefile(outs,$PFTMPFILE)
	"}}}

	" 改行が一致しないので保存し直す "{{{
	exe 'sp' $PFTMPFILE
	set ff=dos
	wq
	"}}}

	" depotならpathに変換
	if path =~ "^//depot.*"
		let path = perforce#get_path_from_depot(path)
	endif

	" 実際に比較 
	call s:pf_diff_tool($PFTMPFILE,path)

endfunction "}}}
function! perforce#pfFind(...) "{{{
	if a:0 == 0
		let str  = input('Find : ')
	else
		let str = a:1
	endif 
	if str !=# ""
		call unite#start([insert(map(split(str),"s:get_dd(v:val)"),'p4_have')])
	endif
endfunction "}}}
function! perforce#pfcmds(cmd,...) "{{{
	" ********************************************************************************
	" p4 コマンドを実行します
	" @param[in]	str		cmd		コマンド
	" @param[in]	str		head	コマンドの前に挿入する
	" @param[in]	str		a:000	コマンドの後に挿入する
	" ********************************************************************************

	let gcmds = ['p4']
	if a:0 > 0 
		call add(gcmds, a:1)
	endif

	if a:cmd =~ 'changes'
		if perforce#data#get('client_changes_only') == 1
			call add(gcmds, '-c '.perforce#get_PFCLIENTNAME())
		endif
	endif 

	call add(gcmds, a:cmd)

	if a:cmd =~ 'clients' || a:cmd =~ 'changes'
		if perforce#data#get('user_changes_only') == 1 
			call add(gcmds, '-u '.perforce#get_PFUSER())
		endif
	endif 


	if perforce#data#get('show_max_flg') == 1
		call add(gcmds, '-m '.perforce#data#get('show_max'))
	endif 


	if a:0 > 1
		call add(gcmds, join(a:000[1:]))
	endif

	let cmd = join(gcmds)
	let rtn_d = {
				\ 'cmd'  : cmd,
				\ 'outs' : split(system(cmd),'\n'),
				\ }

	" Error
	if len(rtn_d.outs) > 0
		if rtn_d.outs[0] =~ "^Perforce client error:"
			let rtn_d.outs = ['ERROR']
		endif
	else
		let rtn_d.outs = ['ERROR']
	endif

	call unite#print_message(rtn_d.cmd)

	" 非表示にするコマンド
	if perforce#data#get('filters_flg') == 1
		let filter_ = join(perforce#data#get('filters'), '\|' ) 
		call filter(rtn_d.outs, 'v:val !~ filter_')
	endif

	return rtn_d
endfunction "}}}
function! s:pf_cmd_rtn_cmd_outs(cmd) "{{{
	" ********************************************************************************
	" @par       コマンドと実行結果を返す
	" @param[in] 
	" @retval    
	" ********************************************************************************
	return extend([a:cmd], split(system(a:cmd), "\n"))
endfunction
"}}}
function! perforce#set_PFCLIENTNAME(str) "{{{
	return s:pf_cmd_rtn_cmd_outs('p4 set P4CLIENT='.a:str)
endfunction "}}}
function! perforce#set_PFPORT(str) "{{{
	return s:pf_cmd_rtn_cmd_outs('p4 set P4PORT='.a:str)
endfunction "}}}
function! perforce#set_PFUSER(str) "{{{
	return s:pf_cmd_rtn_cmd_outs('p4 set P4USER='.a:str)
endfunction "}}}
function! perforce#unite_args(source) "{{{
	"********************************************************************
	" 現在のファイル名を Unite に引数に渡します。
	" @param[in]	source	コマンド
	"********************************************************************

	if 0
		exe 'Unite '.a:source.':'.s:get_dd(expand("%:t"))
	else
		" スペース対策
		" [ ] p4_diff などに修正が必要
		let tmp = a:source.':'.perforce#common#get_pathSrash(expand("%"))
		let tmp = substitute(tmp, ' ','\\ ', 'g')
		let tmp = 'Unite '.tmp
		exe tmp
	endif

endfunction "}}}

"********************************************************************************
"new
function! perforce#get_path_from_depot_with_client(client, depot) "{{{
	let cmd = 'p4 '.a:client.' where "'.a:depot.'"'
	let out = system(cmd)
	return matchstr(out, '.\{-}\zs\w*:.*\ze\n.*')
endfunction "}}}
function! perforce#pfcmds_new_port_only(cmd, head, tail) "{{{
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#pfcmds(a:cmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get_PFPORT()
		let rtns = [tmp]
	else
		let rtns = perforce#pfcmds_with_clients_from_data_port_only(a:cmd, a:head, a:tail)
	endif

	return rtns
endfunction "}}}
function! perforce#pfcmds_new(cmd, head, tail) "{{{
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#pfcmds(a:cmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get_PFPORT().' -c '.perforce#get_PFCLIENTNAME()
		let rtns = [tmp]
	else
		let rtns = perforce#pfcmds_with_clients_from_data(a:cmd, a:head, a:tail)
	endif

	return rtns
endfunction "}}}
function! perforce#pfcmds_new_outs(cmd, head, tail) "{{{
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#pfcmds(a:cmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get_PFPORT().' -c '.perforce#get_PFCLIENTNAME()
		let rtns = [tmp]
	else
		let rtns = perforce#pfcmds_with_clients_from_data(a:cmd, a:head, a:tail)
	endif

	let rtns = perforce#pfcmds_new_get_outs(rtns)

	return rtns
endfunction "}}}
function! perforce#pfcmds_with_client(client,cmd,head,tail) "{{{
	return perforce#pfcmds_with_clients([a:client], a:cmd, a:head, a:tail)
endfunction "}}}
function! perforce#pfcmds_with_clients(clients, cmd, head, tail) "{{{

	let kind = '__common'

	if perforce#data#get('show_max_flg', kind) == 1
		let max = '-m '.perforce#data#get('show_max', kind)
	else 
		let max = ''
	endif 

	if perforce#data#get('user_changes_only',kind) == 1 
		let user = '-u '.perforce#get_PFUSER()
	else 
		let user = ''
	endif

	let rtns = []

	for client in a:clients

		let gcmds = ['p4']
		call add(gcmds, a:head)
		call add(gcmds, client)

		call add(gcmds, a:cmd)
		call add(gcmds, max)

		if a:cmd =~ 'clients' || a:cmd =~ 'changes'
			call add(gcmds, user)

		endif 

		if a:cmd =~ 'changes'
			if perforce#data#get('client_changes_only',kind) == 1
				call add(gcmds, '-c '.a:client)
			endif
		endif 

		call add(gcmds, a:tail)

		let cmd = join(gcmds)

		call add(rtns, {
					\ 'cmd'    : cmd,
					\ 'outs'   : split(system(cmd),'\n'),
					\ 'client' : client,
					\ })

		if perforce#data#get('filters_flg',kind) == 1
			let filter_ = join( perforce#data#get('filters',kind), '\|' ) 
			call filter(rtns[-1].outs, 'v:val !~ filter_')
		endif
	endfor 

	return rtns
endfunction "}}}
function! perforce#pfcmds_with_clients_from_data(cmd,head,tail) "{{{
	let clients = perforce#data#get('clients')
	return  perforce#pfcmds_with_clients_and_unite_mes(clients, a:cmd, a:head, a:tail)
endfunction "}}}
function! perforce#pfcmds_with_clients_from_data_port_only(cmd,head,tail) "{{{
	let ports = map(perforce#data#get('ports'), "'-p '.v:val")
	return  perforce#pfcmds_with_clients_and_unite_mes(ports, a:cmd, a:head, a:tail)
endfunction "}}}
function! perforce#pfcmds_with_clients_from_arg(clients, cmd, head, tail) "{{{
	return  perforce#pfcmds_with_clients_and_unite_mes(a:clients, a:cmd, a:head, a:tail)
endfunction "}}}
function! perforce#pfcmds_with_clients_and_unite_mes(clients, cmd, head, tail) "{{{
	let rtns = perforce#pfcmds_with_clients(a:clients, a:cmd, a:head, a:tail)

	for cmd in map(deepcopy(rtns), "v:val.cmd")
		call unite#print_message('[cmd] '.cmd)
	endfor

	return rtns
endfunction "}}}
function! perforce#pfcmds_new_get_outs(datas) "{{{
	let outs = []
	for data in a:datas
		call extend(outs, get(data, 'outs', []))
	endfor
	return outs
endfunction
"}}}

" rapper
function! perforce#get_source_diff_from_diff(...) 
	return call('perforce#get#file#source_diff', a:000)
endfunction 
let &cpo = s:save_cpo
unlet s:save_cpo

