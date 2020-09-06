/**
 * 
 */
package fi.ishtech.validation.constraints;

import static java.lang.annotation.ElementType.ANNOTATION_TYPE;
import static java.lang.annotation.ElementType.CONSTRUCTOR;
import static java.lang.annotation.ElementType.FIELD;
import static java.lang.annotation.ElementType.METHOD;
import static java.lang.annotation.ElementType.PARAMETER;
import static java.lang.annotation.ElementType.TYPE_USE;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

import java.lang.annotation.Documented;
import java.lang.annotation.Repeatable;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import javax.validation.Constraint;
import javax.validation.Payload;

import fi.ishtech.validation.constraints.HeTu.List;
import fi.ishtech.validation.constraints.validator.HeTuValidator;
import fi.ishtech.validation.enums.HeTuValidationMode;

/**
 * Validates henkilotunnus.<br>
 * <p>
 * Supports three types of validation modes:
 * <ul>
 * <li>{@link HeTuValidationMode#REGEX} - Validates if string is a well-formed in DDMMYYCZZZQ format</li>
 * <li>{@link HeTuValidationMode#DOB} - Validates if DDMMYY is valid date after validating as per {@code REGEX}</li>
 * <li>{@link HeTuValidationMode#CHECKSUM} - Validates checksum value Q after validating as per {@code REGEX} and
 * {@code DOB}. This is default mode.</li>
 * </ul>
 * </p>
 * Accepts {@link CharSequence} (e.g. {@link String}).<br>
 * {@code null} elements are considered valid.<br>
 *
 * @author Muneer Ahmed Syed
 */
@Retention(RUNTIME)
@Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER, TYPE_USE })
@Documented
@Constraint(validatedBy = HeTuValidator.class)
@Repeatable(List.class)
public @interface HeTu {

	String message() default "{fi.ishtech.validation.constraints.HeTu.message}";

	Class<?>[] groups() default {};

	Class<? extends Payload>[] payload() default {};

	HeTuValidationMode mode() default HeTuValidationMode.CHECKSUM;

	/**
	 * Defines several {@code @HeTu} constraints on the same element.
	 *
	 * @see HeTu
	 */
	@Target({ METHOD, FIELD, ANNOTATION_TYPE, CONSTRUCTOR, PARAMETER, TYPE_USE })
	@Retention(RUNTIME)
	@Documented
	public @interface List {
		HeTu[] value();
	}

}
