Name: Soufien Jerou
Matriculation Number: 339034
Title of the Project:"Expense Tracker with Task Management and Weather Integration"
 Project Overview:
This Flutter application is designed to help the users manage tasks, daily expenses, while also providing real-time the current weather information. The application make the users to add, categorize, and track expenses. the application allows users to convert expenses to a base currency using real-time exchange rates. It also allows users to add and manage tasks, set priorities, and include due dates. For staying informed, the application provides real-time weather information based on the user's location.
Overview of the User Experience
Expense Tracking:
The users can easily add their expenses by filling out a simple form, including information like the title, amount, and category.
The application shows expenses in a pie chart, which displays the distribution of expenses by category.The users have the option to switch between different currencies, and the app will automatically convert the expenses to the selected base currency.
Task Management:
The users can create tasks by entering a title, description, category (Important, Urgent, Pending), and due date.
The tasks are shown in a list format, and users can delete tasks once they are completed.
Weather Information:
The application detects the user's current location and shows the weather conditions, such as temperature and weather description.
The weather icon automatically changes according to the current weather conditions. 
Screenshots:
https://drive.google.com/drive/folders/1hzvG2sNaqere3kiTKN9DvtYzMOOx9EtD?usp=sharing
The technologies:
Flutter Packages Used:
fl_chart: For displaying expense data in a pie chart.
shared_preferences: For storing user data like expenses and base currency locally.
table_calendar: For displaying a calendar with holidays and events.
geolocator: For fetching the user's current location to display weather information.
http: For making API calls to fetch exchange rates and weather data.
provider: For state management, particularly for managing tasks.
Implementation Choices:
Currency Conversion: The application uses an external API to fetch real-time exchange rates, allowing users to track expenses in their preferred currency.
Weather Integration: The application uses the OpenWeatherMap API to fetch weather data based on the user's location, providing a personalized experience.
Task Management: Tasks are stored locally using shared_preferences, allowing users to manage their tasks without needing an internet connection.
