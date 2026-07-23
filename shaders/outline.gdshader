shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0);
uniform float outline_width = 1.0;

void fragment()
{
	vec4 sprite = texture(TEXTURE, UV);
	vec2 pixel = TEXTURE_PIXEL_SIZE * outline_width;

	float surrounding_alpha = 0.0;

	surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + vec2( pixel.x, 0.0)).a);
	surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + vec2(-pixel.x, 0.0)).a);
	surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + vec2(0.0,  pixel.y)).a);
	surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + vec2(0.0, -pixel.y)).a);

	surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + vec2( pixel.x,  pixel.y)).a);
	surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + vec2(-pixel.x,  pixel.y)).a);
	surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + vec2( pixel.x, -pixel.y)).a);
	surrounding_alpha = max(surrounding_alpha, texture(TEXTURE, UV + vec2(-pixel.x, -pixel.y)).a);

	float outline_alpha = surrounding_alpha * (1.0 - sprite.a);

	COLOR = mix(outline_color, sprite, sprite.a);
	COLOR.a = max(sprite.a, outline_alpha * outline_color.a);
}
