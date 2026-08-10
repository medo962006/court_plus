import os
from openai import OpenAI

client = OpenAI(
    base_url="https://integrate.api.nvidia.com/v1",
    api_key="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"
)

completion = client.chat.completions.create(
    model="z-ai/glm-5.2",
    messages=[{"role": "user", "content": "Write a python function to check if a number is prime."}],
    temperature=0.7,
    max_tokens=1024,
    stream=True
)

for chunk in completion:
    if chunk.choices and chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")