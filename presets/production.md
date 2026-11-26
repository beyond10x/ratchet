# The production family

Does a deployed service refuse what it must refuse, and do the artifacts it runs verify? Two
presets judge it from reports a project's own tools write before the service goes to
production:

| Preset | What it judges | Evidence |
| --- | --- | --- |
| [`exposure-probes@1`](exposure-probes@1.preset.yaml) | Requests without a valid credential are refused, console routes cannot be reached through the public proxy, and every public listener takes TLS | An imported report of HTTP probes, [`http-probe-report@1`](http-probe-report@1.assessor.yaml) |
| [`artifact-signatures@1`](artifact-signatures@1.preset.yaml) | The signatures of an image and of its provenance verify | An imported report of a verification tool, [`artifact-verification-report@1`](artifact-verification-report@1.assessor.yaml) |

Ratchet sends no request and verifies no signature: the project's probe runner sends the
probes, its verifier checks the signatures, and each writes the report that the program of the
declaration reads. The catalog ships neither the runner, nor the verifier, nor that program.

Every measurement of the family is exact: an assertion per probe or per artifact. Its tolerance
is 0, and no preset of the family has an input for it. An assertion is not among what the first
release that evaluates a gate, 0.1.0, judges ([ROADMAP.md](../ROADMAP.md), "Releases"), so the
family is declared here and no release judges it yet.

[`examples/production-gate.ratchet.yaml`](../examples/production-gate.ratchet.yaml) binds both
presets in the production gate of a service, beside presets of the functional family.

## How to read a row

A row is one measurement, named `<preset>/<assessment>/<measurement>`.

- **Direction** says that the assertion holds.
- **Unit** is the unit the assessor declares for the output. An assertion has none.
- **Tolerance** is the band around the accepted value, and whether an input sets it.
- **Evidence** is the assessor, the output and the scope its results have.

## `exposure-probes@1`

Three groups of probes, each one assertion per probe: a request without a credential, with an
expired one and with one of another tenant is refused; a console route requested through the
public proxy does not answer; a public listener takes TLS and nothing without it.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project that is probed, such as `orders-api` |
| `report` | path | yes | The report of the probe runner, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[staging]` |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `exposure-probes@1/probes/credential-refused` | Holds for every probe | None: an assertion | 0, no input | `http-probe-report@1`, output `credential_refused`, one result per probe of the group |
| `exposure-probes@1/probes/console-unreachable` | Holds for every probe | None: an assertion | 0, no input | `http-probe-report@1`, output `console_unreachable`, one result per probe of the group |
| `exposure-probes@1/probes/tls-enforced` | Holds for every probe | None: an assertion | 0, no input | `http-probe-report@1`, output `tls_enforced`, one result per probe of the group |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `requests-without-valid-credential-refused` | `credential-refused` | `holds` | Not yet: an assertion |
| `console-not-reachable-through-public-proxy` | `console-unreachable` | `holds` | Not yet: an assertion |
| `tls-on-every-public-listener` | `tls-enforced` | `holds` | Not yet: an assertion |

What the program of `http-probe-report@1` returns for a run:

- A probe has an id, such as `probe-0007`, in the same spelling in every run, and a group: the
  credential, the console or the listener. The program reads the group from the report.
- Each output holds one result per probe of its group, at the scope `probe`, with the id of the
  probe as its item. `holds` is `true` where the service answered as the group requires: a
  refusal, no answer through the proxy, a TLS handshake and a refused request without TLS.
- Coverage, in the unit `probe`: a probe that was sent is `executed`, and `passed` or `failed`
  by its result; a probe the report lists without a result is `not_run`. The plan declares
  `not_run: {max: 0}`.

```yaml
presets:
  probes:
    use: exposure-probes@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-api
      report: target/production/probes.json
      environments: [staging]
```

## `artifact-signatures@1`

The signature of every artifact the report lists verifies: the image the service runs and its
provenance.

| Input | Type | Required | What it is |
| --- | --- | --- | --- |
| `subject` | string | yes | The subject of the project whose artifacts are verified, such as `orders-image` |
| `report` | path | yes | The report of the verifier, relative to the root of the tree |
| `environments` | list of string | yes | The target classes the plan runs in, such as `[staging]` |

| Measurement | Direction | Unit | Tolerance | Evidence |
| --- | --- | --- | --- | --- |
| `artifact-signatures@1/verification/signature-verifies` | Holds for every artifact | None: an assertion | 0, no input | `artifact-verification-report@1`, output `verified`, one result per artifact |

| Requirement | Measurement | Comparison | Judged by a release |
| --- | --- | --- | --- |
| `every-signature-verifies` | `signature-verifies` | `holds` | Not yet: an assertion |

What the program of `artifact-verification-report@1` returns for a run:

- `verified` holds one result per artifact of the report, at the scope `artifact`, with the
  name the report gives the artifact as its item, such as `image` and `provenance`. `holds` is
  `true` where the verifier verified its signature.
- Coverage, in the unit `artifact`: an artifact the verifier checked is `executed`, and
  `passed` or `failed` by its result; an artifact the report lists without a result is
  `not_run`. The plan declares `not_run: {max: 0}`.

```yaml
presets:
  signatures:
    use: artifact-signatures@1
    digest: sha256:<digest of the preset file>
    with:
      subject: orders-image
      report: target/production/verification.json
      environments: [staging]
```

## Not expressible yet

What the family needs and `ratchet/1` cannot say. The catalog adds no key to the format; each
point names the place in the specification ([`spec/domains/`](../spec/domains/)) that lacks it.

1. **The kind of a production gate.** A production gate is evaluated on a deployed environment
   and not on a revision. `ratchet.specification.GateKind` has `candidate` and `operational`,
   and an operational gate takes only time-window plans without a `selection`
   ([`docs/design.md`](../docs/design.md) § 5), so the plans of the family carry
   `selection: candidate` and a gate that binds them is a `candidate` gate. The point is
   answered by `judges: {deployment: <class>}`: `ratchet.specification.Gate.judges`
   names the target class whose deployment a candidate gate judges, such as `staging`, and
   `GateKind` keeps its two values. Which revision is deployed in the class stays open in the
   design, so such a gate judges the revision given to `ratchet evaluate --candidate`, and no
   rule ties the plans of the family to the class.
