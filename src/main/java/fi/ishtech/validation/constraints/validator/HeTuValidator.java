/**
 * 
 */
package fi.ishtech.validation.constraints.validator;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

import fi.ishtech.utils.HeTuUtil;
import fi.ishtech.validation.constraints.HeTu;

/**
 * Checks that a given character sequence (e.g. string) is a valid henkilotunnus.
 *
 * @author Muneer Ahmed Syed
 */
public class HeTuValidator implements ConstraintValidator<HeTu, String> {

	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		if (value == null) {
			return true;
		}

		return HeTuUtil.isValidChecksum(value);
	}

}
