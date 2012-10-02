" ********************************************************************************
" �_���a�����܂�
" @param[in]	...
" ********************************************************************************
function! perforce#common#bit#and(...) "{{{
	let nums = copy(a:000)

	" �ő�l�̎擾
	let max = max(nums)

	let val = 1
	let rtn = 0

	while max 
		" �ϊ�
		let rtn += s:and(nums) * val

		" �l�̍X�V
		let nums = map(nums, "v:val / 2")
		let val = val * 2
		let max = max / 2

	endwhile
	
	return rtn
endfunction "}}}
function! perforce#common#bit#or(...) "{{{
	let nums = copy(a:000)

	" �ő�l�̎擾
	let max = max(nums)

	let val = 1
	let rtn = 0

	while max 
		" �ϊ�
		let rtn += s:or(nums) * val

		" �l�̍X�V
		let nums = map(nums, "v:val / 2")
		let val = val * 2
		let max = max / 2

	endwhile
	
	return rtn
endfunction "}}}

" ********************************************************************************
" �ŉ���BIT�̘_��
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
" ������ BIT �������Ă��邩���ׂ�
" @param[in]	num		����
" @param[in]	bit		��
" @retval       flg		bit �̎擾
" ********************************************************************************
function! s:get_bit(num, bit) "{{{
	
	let num1 = float2nr(pow(2, a:bit+1))
	let num2 = num1 / 2 

	let flg = ( a:num % num1 ) / num2 

	return flg

endfunction "}}}

" ********************************************************************************
" ��i������L���� BIT ���̎擾
" @param[in]	bit		Bit �̎擾
" @retval       nums	List ����擾����ԍ�
" ********************************************************************************
function! perforce#common#bit#get_nums_form_bit(bit) "{{{

	let nums = []
	let bit  = a:bit
	let val  = 0

	while bit > 0 
		" BIT ���L���Ȃ烊�X�g�ɒǉ�����
		if bit % 2 
			let nums += [val]
		endif

		" Bit ���X�g�̍X�V
		let bit = bit / 2

		" ���X�g�ʒu�̍X�V
		let val += 1
	endwhile

	return nums

endfunction "}}}
