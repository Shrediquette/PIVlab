//-----------------------------------------------------------------//
// Name        | pco_color_corr_coeff.h      | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Purpose     | PCO - Common PCO functions                        //
//-----------------------------------------------------------------//
// Author      | FRE, Excelitas PCO GmbH                           //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//-----------------------------------------------------------------//
// (c) 2021 Excelitas PCO GmbH * Donaupark 11 *                    //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: pco@excelitas.com           //
//-----------------------------------------------------------------//


// pco_color_corr_coeff.h: Defines helper functions and classes for pco
//

#ifndef PCO_COLOR_CORR_COEFF_H
#define PCO_COLOR_CORR_COEFF_H

struct sRGB_color_correction_coefficients
{
	double da11, da12, da13;
	double da21, da22, da23;
	double da31, da32, da33;
};

typedef struct sRGB_color_correction_coefficients SRGBCOLCORRCOEFF;
#endif
