package fi.ishtech.hetu.validation.constraints.validator;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Locale;
import java.util.Set;

import org.hibernate.validator.HibernateValidator;
import org.junit.jupiter.api.Test;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.ValidatorFactory;
import fi.ishtech.hetu.validation.constraints.HeTu;

class HeTuValidatorTest {

	private static final String VALID_HETU = "010216-855Y";
	private static final String INVALID_HETU = "010216-855X";

	private static class Person {

		@HeTu
		private final String hetu;

		Person(String hetu) {
			this.hetu = hetu;
		}

	}

	private static Set<ConstraintViolation<Person>> validate(String hetu, Locale locale) {
		try (ValidatorFactory factory = Validation.byProvider(HibernateValidator.class)
				.configure()
				.defaultLocale(locale)
				.buildValidatorFactory()) {
			return factory.getValidator().validate(new Person(hetu));
		}
	}

	@Test
	void validAndInvalidHetu() {
		assertTrue(validate(VALID_HETU, Locale.ENGLISH).isEmpty());

		Set<ConstraintViolation<Person>> violations = validate(INVALID_HETU, Locale.ENGLISH);
		assertEquals(1, violations.size());
		assertEquals("Invalid Social Security Number", violations.iterator().next().getMessage());
	}

	@Test
	void invalidHetuMessageInFinnish() {
		Set<ConstraintViolation<Person>> violations = validate(INVALID_HETU, Locale.of("fi"));
		assertEquals(1, violations.size());
		assertEquals("Virheellinen henkilötunnus", violations.iterator().next().getMessage());
	}

}
