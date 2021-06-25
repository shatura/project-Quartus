counter_inst : counter PORT MAP (
		aclr	 => aclr_sig,
		clk_en	 => clk_en_sig,
		clock	 => clock_sig,
		cnt_en	 => cnt_en_sig,
		q	 => q_sig
	);
