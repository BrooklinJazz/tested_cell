export function init(ctx, payload) {
    ctx.importCSS("main.css");

    ctx.root.innerHTML += `
            <section id="editors">
                <p>Assertions</p>
                <textarea class="editor" id="assertions-editor"></textarea>
                <p>Solution</p>
                <textarea class="editor" id="solution-editor"></textarea>
            </section>

            <section id="solution" class="solution">
              <details open>
              <summary id="solution-toggle">Solution:</summary>
              <div id="solution-display"></div>
              </details>
            </section>
            `;

    const editors = ctx.root.querySelector("#editors");

    if (!payload.display_editors) {
        editors.style.display = "none"
    }

    const assertions_editor = ctx.root.querySelector("#assertions-editor");
    const solution_editor = ctx.root.querySelector("#solution-editor");

    assertions_editor.value = payload.assertions;
    solution_editor.value = payload.solution;

    assertions_editor.addEventListener("change", (event) => {
        ctx.pushEvent("update_assertions", { assertions: event.target.value });
    });

    solution_editor.addEventListener("change", (event) => {
        ctx.pushEvent("update_solution", { solution: event.target.value });
    });

    ctx.handleEvent("update_assertions", ({ assertions }) => {
        assertions_editor.value = assertions;
    });


    ctx.handleSync(() => {
        // Synchronously invokes change listeners
        document.activeElement &&
            document.activeElement.dispatchEvent(new Event("change"));
    });

    const solution = ctx.root.querySelector("#solution");
    solution.style.display = "none"
    const solution_display = ctx.root.querySelector("#solution-display");
    solution_display.innerHTML = payload.solution_html

    ctx.handleEvent("update_solution", ({ solution, solution_html }) => {
        solution_editor.value = solution;
        solution_display.innerHTML = solution_html
    });

    ctx.handleEvent("display_solution", ({ solution: solution_text }) => {
        if (solution_text && solution_text != "") {
            solution.style.display = "block"
        }
    });

    ctx.handleEvent("display_editors", ({ display: display }) => {
        if (display) {
            editors.style.display = "block"
        }
        else {
            editors.style.display = "none"
        }
    });
}

