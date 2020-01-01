﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways, ImageEffectAllowedInSceneView]
public class BloomEffect : MonoBehaviour
{
	const int BoxDownPreFilterPass = 0;
	const int BoxDownPass = 1;
	const int BoxUpPass = 2;
	const int ApplyBloomPass = 3;

	public Shader bloomShader;

	[Range(0, 10)]
	public float intensity = 1;

	[Range(1, 16)]
	public int iterations = 1;

	[Range(0, 10)]
	public float threshold = 1;

	private Material bloom;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (bloom == null)
		{
			bloom = new Material(bloomShader);
			bloom.hideFlags = HideFlags.HideAndDontSave;
		}

		bloom.SetFloat("_Threshold", threshold);
		bloom.SetFloat("_Intensity", intensity);

		int width = source.width;
		int height = source.height;
		RenderTextureFormat format = source.format;

		RenderTexture[] textures = new RenderTexture[16];

		RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, format);
		Graphics.Blit(source, currentDestination, bloom, BoxDownPreFilterPass);
		RenderTexture currentSource = currentDestination;

		int i = 1;
		for (; i < iterations; i++)
		{
			width /= 2;
			height /= 2;

			if (width < 2 || height < 2)
			{
				break;
			}

			currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, format);
			Graphics.Blit(currentSource, currentDestination, bloom, BoxDownPass);
			currentSource = currentDestination;
		}

		for (i -= 2; i >= 0; i--)
		{
			currentDestination = textures[i];
			textures[i] = null;
			Graphics.Blit(currentSource, currentDestination, bloom, BoxUpPass);
			RenderTexture.ReleaseTemporary(currentSource);
			currentSource = currentDestination;
		}

		bloom.SetTexture("_SourceTex", source);
		Graphics.Blit(currentSource, destination, bloom, ApplyBloomPass);
		RenderTexture.ReleaseTemporary(currentSource);
	}
}
