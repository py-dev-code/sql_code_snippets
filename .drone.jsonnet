local run() = {
  "name": "run",
  "commands": [
      "echo Hello World"
  ],
};

[
{
  "kind": "pipeline",
  "type": "exec",
  "name": "test",
  "trigger": {
    "event": [
      "push"
    ],
    "branch": [
      "dev"
    ],
  },
  "platform": {
      "os": "linux",
      "arch": "amd64"
  },
  "steps": [
    run(),
  ]
}
]
