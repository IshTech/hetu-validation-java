/**
 * 
 */
package fi.ishtech.validation.enums;

/**
 * Validation modes for HeTu
 *
 * @author Muneer Ahmed Syed
 */
public enum HeTuValidationMode {

	/**
	 * For validating if input string is a well-formed in DDMMYYCZZZQ format.
	 */
	REGEX,

	/**
	 * For validating if DDMMYY part of input is valid date. Includes validation as per {@link #REGEX}.
	 */
	DOB,

	/**
	 * For validating if Q part of input is valid checksum. Includes validation as per {@link #REGEX} and {@link #DOB}.
	 */
	CHECKSUM;

}
