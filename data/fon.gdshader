shader_type canvas_item;

uniform float speed = 1.0;               // скорость анимации
uniform float angle = 20.0;              // угол поворота сетки
uniform vec3 color1 : source_color;      // цвет фона (color1)
uniform vec3 color2 : source_color;      // цвет клеток (color2)
uniform float grid_size = 10.0;          // количество клеток на экран
uniform float grid_spacing = 0.2;        // расстояние между клетками (от 0 до 1)

vec2 rotate(vec2 uv, float rotation_angle) {
    float radians_angle = radians(rotation_angle);
    float cos_angle = cos(radians_angle);
    float sin_angle = sin(radians_angle);
    mat2 rotation_matrix = mat2(vec2(cos_angle, -sin_angle), vec2(sin_angle, cos_angle));
    return uv * rotation_matrix;
}

// Функция для рисования сетки квадратов
float grid(vec2 uv) {
    // Время анимации для смещения клеток
    float time_offset = mod(TIME * speed, 1.0); // Модуль для цикличности движения

    // Разбиваем пространство на сетку с учетом расстояния между клетками
    vec2 grid_coords = floor(uv * grid_size); // вычисление координат клетки

    // Применяем анимацию - сдвигаем координаты сетки по времени
    grid_coords.x += time_offset * grid_size;  // анимация по X
    grid_coords.y += time_offset * grid_size;  // анимация по Y

    // Модифицируем uv, используя сдвиг grid_coords для анимации
    uv = fract(uv * grid_size - grid_coords); // Вычисляем остаток после деления, чтобы анимировать клетки

    // Создаем клетку, с заданной шириной границ
    float border = 1.0 - grid_spacing;  // ширина клетки
    return step(uv.x, border) * step(uv.y, border); // рисуем квадратную границу
}

void fragment() {
    vec2 uv = UV;

    // Поддержка разных разрешений (aspect ratio)
    float a = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
    uv.x *= a;
    
    // Поворот координат
    uv = rotate(uv, angle);

    // Получаем значение для сетки с учетом времени и анимации
    float g = grid(uv);

    // Смешиваем цвета для клеток
    vec3 col = mix(color1, color2, smoothstep(0.0, 1.0, g));
    
    // Устанавливаем цвет пикселя
    COLOR = vec4(col, 1.0); // результат
}
