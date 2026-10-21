package fi.ishtech.hetu.validation.constraints.validator;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Locale;
import java.util.ResourceBundle;

import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import fi.ishtech.hetu.validation.constraints.HeTu;

@TestMethodOrder(OrderAnnotation.class)
class HeTuValidatorTest {

	private static final String VALID_HETU = "010216-855Y";
	private static final String INVALID_HETU = "010216-855X";

	@HeTu
	private String hetuField;

	private HeTuValidator validator() throws NoSuchFieldException {
		HeTuValidator validator = new HeTuValidator();
		validator.initialize(getClass().getDeclaredField("hetuField").getAnnotation(HeTu.class));
		return validator;
	}

	@Test
	@Order(1)
	void testValidHetu() throws NoSuchFieldException {
		assertTrue(validator().isValid(VALID_HETU, null));
	}

	@Test
	@Order(2)
	void testInvalidHetu() throws NoSuchFieldException {
		assertFalse(validator().isValid(INVALID_HETU, null));
	}

	@Test
	@Order(3)
	void testInvalidHetuWithFinnishMessage() throws NoSuchFieldException, NoSuchMethodException {
		assertFalse(validator().isValid(INVALID_HETU, null));

		String template = (String) HeTu.class.getMethod("message").getDefaultValue();
		String key = template.substring(1, template.length() - 1);
		ResourceBundle messages = ResourceBundle.getBundle("ValidationMessages", Locale.of("fi"));

		assertEquals("Virheellinen henkilötunnus", messages.getString(key));
	}

}