String getWeatherBackground(String condition) {
  switch (condition) {
    case 'Clear sky':
    case 'Mainly clear':
      return 'assets/images/weather-day-sunny.jpg';
    case 'Overcast':
    case 'Fog':
    case 'Depositing rime fog':
      return 'assets/images/weather-fog.jpg';
    case 'Partly cloudy':
      return 'assets/images/weather-day-partlycloudy.jpg';
    case 'Drizzle: Light intensity':
    case 'Drizzle: Moderate intensity':
    case 'Drizzle: Dense intensity':
      return 'assets/images/weather-day-cloudy.jpg';
    case 'Rain: Slight intensity':
    case 'Rain: Moderate intensity':
    case 'Rain: Heavy intensity':
    case 'Freezing Rain: Light intensity':
    case 'Freezing Rain: Heavy intensity':
      return 'assets/images/weather-rainy.jpg';
    case 'badai':
      return 'assets/images/weather-storm.jpg';
    default:
      return 'assets/images/weather-day-sunny.jpg';
  }
}
