--
-- Base de datos: `ife`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados`
--

CREATE TABLE IF NOT EXISTS `estados` (
  `ID` int(11) NOT NULL,
  `NOMBRE` varchar(60) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `estados`
--

INSERT INTO `estados` (`ID`, `NOMBRE`) VALUES
(1, 'AGUASCALIENTES'),
(2, 'BAJA CALIFORNIA'),
(3, 'BAJA CALIFORNIA SUR'),
(4, 'CAMPECHE'),
(5, 'COAHUILA'),
(6, 'COLIMA'),
(7, 'CHIAPAS'),
(8, 'CHIHUAHUA'),
(9, 'DISTRITO FEDERAL'),
(10, 'DURANGO'),
(11, 'GUANAJUATO'),
(12, 'GUERRERO'),
(13, 'HIDALGO'),
(14, 'JALISCO'),
(15, 'MÉXICO'),
(16, 'MICHOACÁN'),
(17, 'MORELOS'),
(18, 'NAYARIT'),
(19, 'NUEVO LEÓN'),
(20, 'OAXACA'),
(21, 'PUEBLA'),
(22, 'QUERÉTARO'),
(23, 'QUINTANA ROO'),
(24, 'SAN LUIS POTOSÍ'),
(25, 'SINALOA'),
(26, 'SONORA'),
(27, 'TABASCO'),
(28, 'TAMAULIPAS'),
(29, 'TLAXCALA'),
(30, 'VERACRUZ'),
(31, 'YUCATÁN'),
(32, 'ZACATECAS');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
