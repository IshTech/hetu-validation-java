package fi.ishtech.hetu.validation.constraints.validator;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import fi.ishtech.hetu.validation.constraints.HeTu;
import fi.ishtech.hetu.util.HeTuUtil;
import fi.ishtech.hetu.validation.enums.HeTuValidationMode;

/**
 * Checks that a given {@code CharSequence} (e.g. {@code String}) is a valid henkilotunnus.<br>
 * Validates by Regex or valid data of birth or valid checksum.<br>
 * By default validates by checksum<br>
 *
 * @author Muneer Ahmed Syed
 */
public class HeTuValidator implements ConstraintValidator<HeTu, String> {

	private HeTuValidationMode heTuValidationMode;

	@Override
	public void initialize(HeTu constraintAnnotation) {
		this.heTuValidationMode = constraintAnnotation.mode();
	}

	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		if (value == null) {
			return true;
		}

		switch (heTuValidationMode) {
			case REGEX:
				return HeTuUtil.isValidByRegex(value);

			case DOB:
				return HeTuUtil.isValidDateOfBirth(value);

			case CHECKSUM:
			default:
				return HeTuUtil.isValidChecksum(value);
		}
	}

}