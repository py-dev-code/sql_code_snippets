local run() = {
  "name": "run",
  "commands": [
      "echo Hello World!!!"
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
      "os": "darwin",
      "arch": "amd64"
  },
  "steps": [
    run()
  ]
}
]
