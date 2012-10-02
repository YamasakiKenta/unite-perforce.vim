" ********************************************************************************
" 論理和をします
" @param[in]	...
" ********************************************************************************
function! perforce#common#bit#and(...) "{{{
	let nums = copy(a:000)

	" 最大値の取得
	let max = max(nums)

	let val = 1
	let rtn = 0

	while max 
		" 変換
		let rtn += s:and(nums) * val

		" 値の更新
		let nums = map(nums, "v:val / 2")
		let val = val * 2
		let max = max / 2

	endwhile
	
	return rtn
endfunction "}}}
function! perforce#common#bit#or(...) "{{{
	let nums = copy(a:000)

	" 最大値の取得
	let max = max(nums)

	let val = 1
	let rtn = 0

	while max 
		" 変換
		let rtn += s:or(nums) * val

		" 値の更新
		let nums = map(nums, "v:val / 2")
		let val = val * 2
		let max = max / 2

	endwhile
	
	return rtn
endfunction "}}}

" ********************************************************************************
" 最下位BITの論理
" @param[in]	
" @retval       
" ********************************************************************************
function! s:and(nums) "{{{
	return eval(join(map(copy(a:nums), "v:val%2"),'*')) ? 1 : 0
endfunction "}}}
function! s:or(nums) "{{{
	return eval(join(map(copy(a:nums), "v:val%2"),'+')) ? 1 : 0
endfunction "}}}

" ********************************************************************************
" 数字に BIT がたっているか調べる
" @param[in]	num		数字
" @param[in]	bit		幅
" @retval       flg		bit の取得
" ********************************************************************************
function! s:get_bit(num, bit) "{{{
	
	let num1 = float2nr(pow(2, a:bit+1))
	let num2 = num1 / 2 

	let flg = ( a:num % num1 ) / num2 

	return flg

endfunction "}}}

" ********************************************************************************
" 二進数から有効な BIT 幅の取得
" @param[in]	bit		Bit の取得
" @retval       nums	List から取得する番号
" ********************************************************************************
function! perforce#common#bit#get_nums_form_bit(bit) "{{{

	let nums = []
	let bit  = a:bit
	let val  = 0

	while bit > 0 
		" BIT が有効ならリストに追加する
		if bit % 2 
			let nums += [val]
		endif

		" Bit リストの更新
		let bit = bit / 2

		" リスト位置の更新
		let val += 1
	endwhile

	return nums

endfunction "}}}
