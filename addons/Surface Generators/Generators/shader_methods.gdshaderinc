//Methods that can be used by other shaders to compute values

float hash(uint n)
 {
	// integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
	n = n * (n * n * 15731U + 789221U) + 1376312589U;
	return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
}

float lerp(float start, float end, float delta) {
	return start * (1.0 - delta) + end * delta;
}