export function init(ctx, payload) {
    ctx.importCSS("main.css");

    ctx.root.innerHTML += `
            <section class="container">
                <p id="title">${payload.title}</p>
                <section id="editors">
                    <input class="editor" id="title-editor"></input>
                    <p>Assertions</p>
                    <textarea class="editor" id="assertions-editor"></textarea>
                    <p>Solution</p>
                    <textarea class="editor" id="solution-editor"></textarea>
                </section>
            </section>

            <section id="solution" class="solution">
                <details open>
                    <summary id="solution-toggle">Possible Solution:</summary>
                    <div id="solution-display"></div>
                </details>
            </section>
            `;

    const editors = ctx.root.querySelector("#editors");
    const title_editor = ctx.root.querySelector("#title-editor");
    const title = ctx.root.querySelector("#title");
    const assertions_editor = ctx.root.querySelector("#assertions-editor");
    const solution_editor = ctx.root.querySelector("#solution-editor");

    editors.style.display = "none"
    title_editor.value = payload.title;
    title.value = payload.title;
    assertions_editor.value = payload.assertions;
    solution_editor.value = payload.solution;

    title_editor.addEventListener("change", (event) => {
        ctx.pushEvent("update_title", { title: event.target.value });
    });

    assertions_editor.addEventListener("change", (event) => {
        ctx.pushEvent("update_assertions", { assertions: event.target.value });
    });

    solution_editor.addEventListener("change", (event) => {
        ctx.pushEvent("update_solution", { solution: event.target.value });
    });

    title.addEventListener("dblclick", () => {
        if (editors.style.display == "block") {
            editors.style.display = "none"
        } else {
            editors.style.display = "block"
        }
    });

    ctx.handleEvent("update_assertions", ({ assertions }) => {
        assertions_editor.value = assertions;
    });

    ctx.handleEvent("update_title", ({ title: title_text }) => {
        title_editor.value = title_text;
        title.innerHTML = title_text;
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
}

