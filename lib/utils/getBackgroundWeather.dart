String getWeatherBackground(String condition) {
  switch (condition) {
    case 'Langit Cerah':
    case 'Cerah Berawan':
      return 'assets/images/weather-day-sunny.jpg';
    case 'Kabut':
    case 'Kabut Beku':
      return 'assets/images/weather-fog.jpg';
    case 'Sebagian Berawan':
    case 'Berawan':
      return 'assets/images/weather-day-partlycloudy.jpg';
    case 'Gerimis':
    case 'Gerimis Beku':
      return 'assets/images/weather-day-cloudy.jpg';
    case 'Hujan':
    case 'Hujan Beku':
      return 'assets/images/weather-rainy.jpg';
    case 'Badai':
      return 'assets/images/weather-storm.jpg';
    default:
      return 'assets/images/weather-day-sunny.jpg';
  }
}
