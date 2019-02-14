gen rural_output_per_worker = Ar * (L/N)^beta
gen urbanization_premium = (L_bar/L)^beta
gen relative_price_effect = (rural_employment + urban_employment/Pu_Pr) / employment
gen urbanization_contribution = urbanization_premium * relative_price_effect
