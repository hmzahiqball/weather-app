String getWeatherBackground(String condition) {
  switch (condition.toLowerCase()) {
    case 'cerah':
      return 'assets/images/weather-day-sunny.jpg';
    case 'berawan':
      return 'assets/images/weather-day-cloudy.jpg';
    case 'sebagian berawan':
      return 'assets/images/weather-day-partlycloudy.jpg';
    case 'hujan':
      return 'assets/images/weather-rainy.jpg';
    case 'kabut':
      return 'assets/images/weather-fog.jpg';
    case 'badai':
      return 'assets/images/weather-storm.jpg';
    default:
      return 'assets/images/weather-day-sunny.jpg';
  }
}
