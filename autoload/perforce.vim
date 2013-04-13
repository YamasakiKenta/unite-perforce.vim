let s:save_cpo = &cpo
set cpo&vim

function! s:get_path_from_where(str) "{{{
	return matchstr(a:str, '.\{-}\zs\w*:.*\ze\n.*')
endfunction
"}}}
function! s:is_p4_have_from_have(str) "{{{

	if a:str =~ '- file(s) not on client.'
		let flg = 0
	else
		let flg = 1
	endif

	return flg

endfunction
"}}}
function! s:pf_diff_tool(file,file2) "{{{
	if perforce#data#get('is_vimdiff_flg')
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call perforce#util#map_diff()
	else
		let cmd = perforce#data#get('diff_tool')

		if cmd =~ 'kdiff3'
			call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2).' -o '.perforce#common#Get_kk(a:file2))
		else
			" winmergeu
			call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2))
		endif
	endif
endfunction
"}}}
function! s:get_ChangeNum_from_changes(str) "{{{
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction
"}}}

function! perforce#get_tmp_file() "{{{
	let g:perforce_tmp_dir  = get(g:, 'perforce_tmp_dir', '~/.perforce/' )
	let fname               = g:perforce_tmp_dir.'/tmpfile'

	if !isdirectory(g:perforce_tmp_dir)
		call mkdir(g:perforce_tmp_dir)
	endif

	return fname
endfunction
"}}}
function! perforce#get_dd(str) "{{{
	return len(a:str) ? '//...'.perforce#common#get_kk(a:str).'...' : ''
endfunction
"}}}
function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" ���ʂ̏o�͂��s��
	" @param[in]	str		�\�����镶��
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


endfunction
"}}}
function! perforce#get_pfchanges(context,outs,kind) "{{{
	" ********************************************************************************
	" p4_changes Untie �p�� �Ԃ�l��Ԃ�
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
endfunction
"}}}
function! perforce#get_source_file_from_path(path) "{{{
	" ********************************************************************************
	" �����̏o�͂��AUnite��jump_list��������
	" @param[in]	outs		�����̃f�[�^
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
endfunction
"}}}
function! perforce#init() "{{{

	" �N���C�A���g�f�[�^�̓ǂݍ���
	call perforce#get#PFCLIENTPATH()

	" �ݒ�̎擾
	call perforce#data#init()
endfunction
"}}}
function! perforce#is_p4_have(str) "{{{
	" ********************************************************************************
	" �N���C�A���g�Ƀt�@�C�������邩���ׂ�
	" @param[in]	str				�t�@�C���� , have �̕Ԃ�l
	" @retval       flg		TRUE 	���݂���
	" @retval       flg		FLASE 	���݂��Ȃ�
	" ********************************************************************************
	let str = system('p4 have '.perforce#common#get_kk(a:str))
	let flg = s:is_p4_have_from_have(str)
	return flg
endfunction
"}}}
function! perforce#matomeDiffs(...) "{{{
	" new file �p�ɂ����ŏ�����
	let datas = []

	echo a:000
	for chnum in a:000
		" �f�[�^�̎擾 {{{
		let outs = perforce#cmd#base('describe -ds','',chnum).outs

		" ��ƒ��̃t�@�C��
		if outs[0] =~ '\*pending\*' || chnum == 'default'
			let files = perforce#cmd#base('opened','','-c '.chnum).outs
			call map(files, "perforce#get#depot#from_opened(v:val)")

			let outs = []
			for file in files 
				let list_tmps = perforce#cmd#base('diff -ds','',file).outs

				for list_tmp in list_tmps
					if list_tmp =~ '- file(s) not opened for edit.'
						let file_tmp = substitute(file, '.*[\/]','','')
						let path = perforce#get#path#from_depot(file)
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
	"�f�[�^�̏o�� {{{
	let outs = []
	for data in datas 
		let outs += [data["files"]."\t\t".data["adds"]."\t".data["deleteds"]."\t".data["changeds"]]
	endfor

	call perforce#common#LogFile('p4log', 0, outs)
	"}}}
endfunction
"}}}
function! perforce#pfChange(str,...) "{{{
	"********************************************************************************
	" �`�F���W���X�g�̍쐬
	" @param[in]	str		�`�F���W���X�g�̃R�����g
	" @param[in]	...		�ҏW����`�F���W���X�g�ԍ�
	"********************************************************************************
	"
	"�`�F���W�ԍ��̃Z�b�g ( ���������邩 )
	let chnum     = get(a:,'1','')

	"ChangeList�̐ݒ�f�[�^���ꎞ�ۑ�����
	let tmp = system('p4 change -o '.chnum)                          

	"�R�����g�̕ҏW
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\nFiles:\)\?','\t'.a:str.'\n','') 

	" �V�K�쐬�̏ꍇ�́A�t�@�C�����܂܂Ȃ�
	if chnum == "" | let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') | endif

	"�ꎞ�t�@�C���̏����o��
	call writefile(split(tmp,'\n'),perforce#get_tmp_file())

	" �`�F���W���X�g�̍쐬
	" �� client �ɑΉ�����
	let out = split(system('more '.perforce#common#get_kk(perforce#get_tmp_file()).' | p4 change -i', '\n'))

	return out

endfunction
"}}}
function! perforce#pfFind(...) "{{{
	if a:0 == 0
		let str  = input('Find : ')
	else
		let str = a:1
	endif 
	if str !=# ""
		call unite#start([insert(map(split(str),"perforce#get_dd(v:val)"),'p4_have')])
	endif
endfunction
"}}}
function! perforce#unite_args(source) "{{{
	"********************************************************************
	" @par          ���݂̃t�@�C������ Unite �Ɉ����ɓn���܂��B
	" @param[in]	source	�R�}���h
	"********************************************************************

	if 0
		exe 'Unite '.a:source.':'.perforce#get_dd(expand("%:t"))
	else
		" �X�y�[�X�΍�
		" [ ] p4_diff �ȂǂɏC�����K�v
		let tmp = a:source.':'.perforce#common#get_pathSrash(expand("%"))
		let tmp = substitute(tmp, ' ','\\ ', 'g')
		let tmp = 'Unite '.tmp
		exe tmp
	endif

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

